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

    // Full implementation (base32hex decode + LZ77 decompress) added in Step 4
    static func decode(_ string: String) -> PayBySquarePayment? {
        return nil
    }
}
