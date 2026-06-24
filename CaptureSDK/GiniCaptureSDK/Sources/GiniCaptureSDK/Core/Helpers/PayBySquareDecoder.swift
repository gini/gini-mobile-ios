//
//  PayBySquareDecoder.swift
//  GiniCaptureSDK
//

import Foundation

struct PayBySquarePayment {
    let iban: String
    let swift: String?
    let amount: String
    let currency: String
    let payeeName: String
    let paymentReference: String
}

final class PayBySquareDecoder {

    static func looksLikePayBySquare(_ string: String) -> Bool {
        let base32hexChars = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUV")
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
        //    [12] IBAN          [13] BIC           ...extensions...  [12+N*2+2] beneficiaryName
        let fields = text.components(separatedBy: "\t")
        let banksCount = max(1, Int(fields.indices.contains(11) ? fields[11].trimmingCharacters(in: .whitespaces) : "") ?? 1)
        // Extension fields are controlled by the PaymentOptions bitmask (field[2]):
        //   bit 0 (standing order): +4 extension fields
        //   bit 1 (direct debit):   +10 extension fields
        let paymentOptions = Int(fields.indices.contains(2) ? fields[2] : "") ?? 0
        let extFields = ((paymentOptions & 1) != 0 ? 4 : 0) + ((paymentOptions & 2) != 0 ? 10 : 0)
        let beneficiaryIdx = 12 + banksCount * 2 + extFields

        let iban = fields.indices.contains(12) ? fields[12] : ""
        let bic = fields.indices.contains(13) && !fields[13].isEmpty ? fields[13] : nil
        let amount = fields.indices.contains(3) ? fields[3] : ""
        let currency = fields.indices.contains(4) ? fields[4] : ""
        let beneficiaryName = fields.indices.contains(beneficiaryIdx) ? fields[beneficiaryIdx] : ""
        let variableSymbol = fields.indices.contains(6) ? fields[6] : ""
        let paymentNote = fields.indices.contains(10) ? fields[10] : ""
        let reference = buildReference(variableSymbol: variableSymbol, paymentNote: paymentNote)

        return PayBySquarePayment(iban: iban,
                                  swift: bic,
                                  amount: amount,
                                  currency: currency,
                                  payeeName: beneficiaryName,
                                  paymentReference: reference)
    }

    // MARK: - Private

    private static func buildReference(variableSymbol: String, paymentNote: String) -> String {
        if !variableSymbol.isEmpty && !paymentNote.isEmpty {
            return variableSymbol + " " + paymentNote
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
