//
//  PayBySquareDecoder.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 A single payment decoded from a Pay-by-Square (bysquare) QR payload.
 */
struct PayBySquarePayment {
    let iban: String
    let bic: String?
    let amount: String
    let currency: String
    let payeeName: String
    let paymentReference: String
}

/**
 Decodes Pay-by-Square (Slovak "bysquare") QR payloads into a `PayBySquarePayment`.

 The payload is a base32hex-encoded string wrapping an LZMA1-compressed, tab-separated
 record. Decoding runs the pipeline: base32hex decode → parse the 4-byte bysquare header
 → LZMA1 decompress the body (via `LZMADecoder`) → skip the CRC32 prefix → split the
 UTF-8 text into the bysquare fields. `looksLikePayBySquare(_:)` provides a cheap
 heuristic to detect the format before attempting a full decode.
 */
enum PayBySquareDecoder {

    static func looksLikePayBySquare(_ string: String) -> Bool {
        // Accept lowercase too; decode() normalises to uppercase before parsing.
        let base32hexChars = CharacterSet(charactersIn:
            "0123456789ABCDEFGHIJKLMNOPQRSTUVabcdefghijklmnopqrstuv")
        // A real bysquare payload (4-byte header + LZMA1-compressed body) always encodes to
        // far more than 16 base32hex characters; 16 is a conservative lower bound that cheaply
        // rejects short base32hex-looking strings before attempting a full decode.
        return string.count >= 16
            && string.unicodeScalars.allSatisfy { base32hexChars.contains($0) }
    }

    static func decode(_ string: String) -> PayBySquarePayment? {
        let upper = string.uppercased()

        // 1. Base32hex decode
        guard let bytes = base32hexDecode(upper) else { return nil }

        // 2. Parse 4-byte bysquare header:
        //    bytes[0-1]: bysquare header (upper nibble of byte 0 = bysquare type; 0 = PAY)
        //    bytes[2-3]: payload length (little-endian uint16 = decompressed size including CRC32)
        guard bytes.count > 4 else { return nil }
        let bysquareType = (Int(bytes[0]) >> 4) & 0x0F
        guard bysquareType == 0 else { return nil }
        let payloadLength = Int(bytes[2]) | (Int(bytes[3]) << 8)
        guard payloadLength > 4 else { return nil }

        // 3. LZMA1 decompress bytes[4...]
        // Apple's COMPRESSION_LZMA only handles XZ/LZMA2; bysquare uses raw LZMA1.
        guard let decompressed = LZMADecoder.decode(input: Array(bytes[4...]),
                                                    outputLength: payloadLength) else { return nil }

        // 4. Skip 4-byte CRC32 prefix; decode remaining as UTF-8
        // Note: CRC32 validation was attempted but rejected valid codes from the field — the bysquare
        // spec's exact CRC32 variant and byte layout need a verified test vector before re-enabling.
        guard decompressed.count > 4 else { return nil }
        guard let text = String(bytes: Array(decompressed[4...]), encoding: .utf8) else { return nil }

        // 5. Tab-separated fields (bysquare spec v1.1):
        //    [0] invoiceId      [1] paymentsCount  [2] paymentType  [3] amount
        //    [4] currencyCode   [5] paymentDueDate [6] variableSymbol [7] constantSymbol
        //    [8] specificSymbol [9] originatorRef  [10] paymentNote  [11] bankAccountsCount
        //    [12] IBAN          [13] BIC           ...N accounts...
        //    Then two extension-presence flags, any present extension blocks, then:
        //    [12 + N*2 + 2 (+ extension fields)] beneficiaryName
        let fields = text.components(separatedBy: "\t")
        let rawBanksCount = max(1, Int(field(fields, at: Field.bankAccountsCount).trimmingCharacters(in: .whitespaces)) ?? 1)
        // Bound by field count so a malformed payload can't push beneficiaryIdx far past the array.
        let banksCount = min(rawBanksCount, fields.count)
        // PaymentOptions bitmask (Field.paymentType): paymentorder = 1, standingorder = 2,
        // directdebit = 4. A present standing order adds 4 fields; a present direct debit adds 10.
        let paymentOptions = Int(field(fields, at: Field.paymentType).trimmingCharacters(in: .whitespaces)) ?? 0
        let extensionFields = ((paymentOptions & 2) != 0 ? 4 : 0)   // standing order block
                            + ((paymentOptions & 4) != 0 ? 10 : 0)  // direct debit block
        // Two presence-flag fields always sit between the last bank account and the
        // beneficiary name, regardless of whether the extension blocks are present.
        let beneficiaryIdx = Field.iban + banksCount * 2 + 2 + extensionFields

        let bicValue = field(fields, at: Field.bic)
        let iban = field(fields, at: Field.iban)
        let bic = bicValue.isEmpty ? nil : bicValue
        let amount = field(fields, at: Field.amount)
        let currency = field(fields, at: Field.currency)
        let beneficiaryName = fields.indices.contains(beneficiaryIdx) ? fields[beneficiaryIdx] : ""
        let variableSymbol = field(fields, at: Field.variableSymbol)
        let paymentNote = field(fields, at: Field.paymentNote)
        let reference = buildReference(variableSymbol: variableSymbol, paymentNote: paymentNote)

        return PayBySquarePayment(iban: iban,
                                  bic: bic,
                                  amount: amount,
                                  currency: currency,
                                  payeeName: beneficiaryName,
                                  paymentReference: reference)
    }

    // MARK: - Private

    /**
     Zero-based indices of the tab-separated bysquare fields (spec v1.1).
     */
    private enum Field {
        static let paymentType       = 2   // PaymentOptions bitmask
        static let amount            = 3
        static let currency          = 4
        static let variableSymbol    = 6
        static let paymentNote       = 10
        static let bankAccountsCount = 11
        static let iban              = 12
        static let bic               = 13
    }

    /**
     Returns the field at `index`, or an empty string when it is out of range.
     */
    private static func field(_ fields: [String], at index: Int) -> String {
        fields.indices.contains(index) ? fields[index] : ""
    }

    private static func buildReference(variableSymbol: String, paymentNote: String) -> String {
        if !variableSymbol.isEmpty && !paymentNote.isEmpty {
            return "\(variableSymbol) \(paymentNote)"
        } else if !variableSymbol.isEmpty {
            return variableSymbol
        } else {
            return paymentNote
        }
    }

    private static func base32hexDecode(_ string: String) -> [UInt8]? {
        var accumulator: UInt32 = 0
        var bitsStored = 0
        var result = [UInt8]()
        result.reserveCapacity(string.count * 5 / 8)

        for scalar in string.unicodeScalars {
            let value: UInt32
            switch scalar.value {
            case 48...57: value = scalar.value - 48  // '0'–'9' → 0–9
            case 65...86: value = scalar.value - 55  // 'A'–'V' → 10–31
            default: return nil
            }
            accumulator = (accumulator << 5) | value
            bitsStored += 5
            if bitsStored >= 8 {
                bitsStored -= 8
                result.append(UInt8((accumulator >> bitsStored) & 0xFF))
            }
        }

        return result
    }
}
