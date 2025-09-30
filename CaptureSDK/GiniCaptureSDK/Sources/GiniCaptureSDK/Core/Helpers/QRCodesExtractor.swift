//
//  QRCodeExtractor.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/8/17.
//

import Foundation
import GiniUtilites

public enum QRCodesFormat {
    case epc06912
    case eps4mobile
    case bezahl
    case giniQRCode

    var prefixURL: String {
        switch self {
        case .epc06912:
            return "BCD"
        case .eps4mobile:
            return "epspayment://"
        case .bezahl:
            return "bank://"
        case .giniQRCode:
            return "https://pay.gini.net/"
        }
    }
}

public final class QRCodesExtractor {

    public static let epsCodeUrlKey = "epsPaymentQRCodeUrl"
    public static let giniCodeUrlKey = "giniPaymentQRCodeUrl"

    class func extractParameters(from string: String, withFormat qrCodeFormat: QRCodesFormat?) -> [String: String] {
        switch qrCodeFormat {
        case .some(.bezahl):
            return extractParameters(fromBezhalCodeString: string)
        case .some(.epc06912):
            return extractParameters(fromEPC06912CodeString: string)
        case .some(.eps4mobile):
            return [epsCodeUrlKey: string]
        case .some(.giniQRCode):
            return [giniCodeUrlKey: string]
        case .none:
            return [:]
        }
    }

    class func extractParameters(fromBezhalCodeString string: String) -> [String: String] {
        var parameters: [String: String] = [:]

        if let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let queryParameters = URL(string: encodedString)?.queryParameters {

            let queryParametersDecoded = queryParameters.reduce(into: [String: Any]()) { result, parameter in
                if let decodedValue = (parameter.value as? String)?.removingPercentEncoding {
                    result[parameter.key] = decodedValue
                }
            }

            if let bic = queryParametersDecoded["bic"] as? String {
                parameters["bic"] = bic
            }
            if let paymentRecipient = queryParametersDecoded["name"] as? String {
                parameters["paymentRecipient"] = paymentRecipient
            }

            if let iban = queryParametersDecoded["iban"] as? String,
                IBANValidator().isValid(iban: iban) {
                parameters["iban"] = iban
            }
            if let paymentReference = queryParametersDecoded["reason"] as? String ??
                queryParameters["reason1"] as? String {
                parameters["paymentReference"] = paymentReference
            }
            if let amount = queryParametersDecoded["amount"] as? String,
                let amountNormalized = normalize(amount: amount,
                                                 currency: queryParameters["currency"] as? String ?? "EUR") {
                parameters["amountToPay"] = amountNormalized
            }
        }

        return parameters
    }

    class func extractParameters(fromEPC06912CodeString string: String) -> [String: String] {
        let lines = string.splitlines
        var parameters: [String: String] = [:]

        if lines.indices.contains(4) && !lines[4].isEmpty {
            parameters["bic"] = lines[4]
        } else {
            parameters["bic"] = ""
        }

        if lines.indices.contains(5) && !lines[5].isEmpty {
            parameters["paymentRecipient"] = lines[5]
        } else {
            parameters["paymentRecipient"] = ""
        }

        if lines.indices.contains(9) && !lines[9].isEmpty {
            parameters["paymentReference"] = lines[9]
        } else {
            parameters["paymentReference"] = ""
        }

        // if index out of range, return empty string

        if lines.indices.contains(6) && IBANValidator().isValid(iban: lines[6]) {
            parameters["iban"] = lines[6]
        } else {
            parameters["iban"] = ""
        }

        if lines.indices.contains(7) {
            if let amountToPay = normalize(amount: lines[7], currency: nil) {
                parameters["amountToPay"] = amountToPay
            } else {
                parameters["amountToPay"] = ""
            }
        } else {
            parameters["amountToPay"] = ""
        }

        return parameters
    }

    fileprivate class func normalize(amount: String, currency: String?) -> String? {
        let regexCurrency = try? NSRegularExpression(pattern: "[aA-zZ]", options: [])
        let length = amount.count < 3 ? amount.count : 3

        if regexCurrency?.numberOfMatches(in: amount, options: [], range: NSRange(location: 0, length: length)) == 3 {
            let currency = String(amount[..<String.Index(utf16Offset: 3, in: amount)])
            let quantity = String(amount[String.Index(utf16Offset: 3, in: amount)...])
            return quantity + ":" + currency
        } else if let currency = currency {
            return amount + ":" + currency
        }

        return nil
    }
}
