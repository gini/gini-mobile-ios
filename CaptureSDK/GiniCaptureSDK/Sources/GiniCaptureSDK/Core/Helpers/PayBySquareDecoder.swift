//
//  PayBySquareDecoder.swift
//  GiniCaptureSDK
//

import Foundation
import Compression

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
        let upper = string.uppercased()
        let base32hexChars = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUV")
        return upper.count >= 16
            && upper.unicodeScalars.allSatisfy { base32hexChars.contains($0) }
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

        // 3. LZMA decompress bytes[4...]
        guard let decompressed = lzmaDecompress(rawBody: Array(bytes[4...]),
                                                payloadLength: payloadLength) else { return nil }

        // 4. Skip 4-byte CRC32 prefix; decode remaining as UTF-8
        guard decompressed.count > 4 else { return nil }
        guard let text = String(bytes: Array(decompressed[4...]), encoding: .utf8) else { return nil }

        // 5. Tab-separated fields (bysquare spec v1.1):
        //    [0] invoiceId      [1] paymentsCount  [2] paymentType  [3] amount
        //    [4] currencyCode   [5] paymentDueDate [6] variableSymbol [7] constantSymbol
        //    [8] specificSymbol [9] originatorRef  [10] paymentNote  [11] bankAccountsCount
        //    [12] IBAN          [13] BIC           ...extensions...  [12+N*2+2] beneficiaryName
        let fields = text.components(separatedBy: "\t")
        let banksCount = max(1, Int(fields.indices.contains(11) ? fields[11].trimmingCharacters(in: .whitespaces) : "") ?? 1)
        let beneficiaryIdx = 12 + banksCount * 2 + 2
        guard fields.indices.contains(beneficiaryIdx) else { return nil }

        let iban = fields.indices.contains(12) ? fields[12] : ""
        let bic = fields.indices.contains(13) && !fields[13].isEmpty ? fields[13] : nil
        let amount = fields.indices.contains(3) ? fields[3] : ""
        let currency = fields.indices.contains(4) ? fields[4] : ""
        let beneficiaryName = fields[beneficiaryIdx]
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

    /// Decompresses raw LZMA1 body (without the 13-byte LZMA "alone" header) using
    /// Apple's Compression framework. Reconstructs the standard LZMA "alone" header
    /// with the fixed bysquare parameters (lc=3, lp=0, pb=2, dictSize=131072) before
    /// passing the data to the decoder.
    private static func lzmaDecompress(rawBody: [UInt8], payloadLength: Int) -> [UInt8]? {
        // Build the 13-byte LZMA "alone" header:
        //   1 byte  properties: 0x5D = (pb*5+lp)*9+lc = (2*5+0)*9+3 = 93 = 0x5D
        //   4 bytes dictionary size: 131072 = 0x00020000, little-endian
        //   8 bytes uncompressed size: payloadLength, little-endian uint64
        let header: [UInt8] = [
            0x5D,
            0x00, 0x00, 0x02, 0x00,
            UInt8( payloadLength        & 0xFF),
            UInt8((payloadLength >>  8) & 0xFF),
            UInt8((payloadLength >> 16) & 0xFF),
            UInt8((payloadLength >> 24) & 0xFF),
            0, 0, 0, 0
        ]

        let fullData = header + rawBody
        var dest = [UInt8](repeating: 0, count: payloadLength)

        let result = fullData.withUnsafeBytes { srcPtr -> Int in
            guard let srcBase = srcPtr.baseAddress else { return 0 }
            return dest.withUnsafeMutableBytes { dstPtr -> Int in
                guard let dstBase = dstPtr.baseAddress else { return 0 }
                return compression_decode_buffer(
                    dstBase.assumingMemoryBound(to: UInt8.self),
                    payloadLength,
                    srcBase.assumingMemoryBound(to: UInt8.self),
                    fullData.count,
                    nil,
                    COMPRESSION_LZMA
                )
            }
        }

        guard result == payloadLength else { return nil }
        return dest
    }
}
