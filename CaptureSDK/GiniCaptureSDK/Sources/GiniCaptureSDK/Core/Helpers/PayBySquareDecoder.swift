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
    let paymentNote: String
}

final class PayBySquareDecoder {

    static func looksLikePayBySquare(_ string: String) -> Bool {
        let base32hexChars = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUV")
        return string.count >= 16
            && string.unicodeScalars.allSatisfy { base32hexChars.contains($0) }
    }

    static func decode(_ string: String) -> PayBySquarePayment? {
        // 1. Base32hex decode: map each char to 5-bit value, pack into bytes
        guard let bytes = base32hexDecode(string) else { return nil }

        // 2. Parse header (3 bytes):
        //    - Byte 0 bits 3-0: document type (0 = Payment)
        //    - Bytes 1-2: decompressed data length, little-endian uint16
        guard bytes.count >= 3 else { return nil }
        let docType = bytes[0] & 0x0F
        guard docType == 0 else { return nil }
        let decompressedLength = Int(bytes[1]) | (Int(bytes[2]) << 8)

        // 3. LZ77 decompress bytes[3...]
        guard let decompressed = lz77Decompress(Array(bytes[3...]),
                                                expectedLength: decompressedLength) else { return nil }

        // 4. Decode as UTF-8
        guard let text = String(bytes: decompressed, encoding: .utf8) else { return nil }

        // 5. Tab-separated fields per BYSQUARE Payment spec:
        //    [0] InvoiceID  [1] PaymentOptions  [2] Amount      [3] CurrencyCode
        //    [4] DueDate    [5] VariableSymbol  [6] ConstSymbol [7] SpecificSymbol
        //    [8] OriginatorRefInfo  [9] PaymentNote  [10] BankAccountsCount
        //    [11] IBAN  [12] SWIFT/BIC  [13] PayeeName
        let fields = text.components(separatedBy: "\t")
        guard fields.count > 13 else { return nil }

        return PayBySquarePayment(iban: fields[11],
                                  swift: fields[12].isEmpty ? nil : fields[12],
                                  amount: fields[2],
                                  currency: fields[3],
                                  payeeName: fields[13],
                                  paymentNote: fields[9])
    }

    // MARK: - Private

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

    // Haruhiko Okumura LZSS variant used by the BYSQUARE standard.
    // Window: 4096-byte ring buffer initialised to 0x20 (space).
    // Control byte LSB-first: 1 = literal, 0 = back-reference (2 bytes).
    // Back-reference encoding: b0 = low 8 bits of position,
    //   b1 high-nibble = bits 11-8 of position, b1 low-nibble = length - 3.
    private static func lz77Decompress(_ data: [UInt8], expectedLength: Int) -> [UInt8]? {
        let windowSize = 4096
        let minMatchLength = 3   // THRESHOLD + 1

        var ringBuf = [UInt8](repeating: 0x20, count: windowSize)
        var r = windowSize - 18  // initial insert position (= 4078)
        var output = [UInt8]()
        output.reserveCapacity(expectedLength)

        var i = 0

        while i < data.count, output.count < expectedLength {
            let flags = Int(data[i])
            i += 1

            for bit in 0..<8 {
                guard i < data.count, output.count < expectedLength else { break }

                if flags & (1 << bit) != 0 {
                    // Literal byte
                    let c = data[i]
                    i += 1
                    output.append(c)
                    ringBuf[r] = c
                    r = (r + 1) % windowSize
                } else {
                    // Back-reference
                    guard i + 1 < data.count else { return nil }
                    let b0 = Int(data[i])
                    let b1 = Int(data[i + 1])
                    i += 2

                    var position = b0 | ((b1 & 0xF0) << 4)
                    let length = (b1 & 0x0F) + minMatchLength

                    for _ in 0..<length {
                        guard output.count < expectedLength else { break }
                        let c = ringBuf[position % windowSize]
                        output.append(c)
                        ringBuf[r] = c
                        r = (r + 1) % windowSize
                        position += 1
                    }
                }
            }
        }

        return output.count == expectedLength ? output : nil
    }
}
