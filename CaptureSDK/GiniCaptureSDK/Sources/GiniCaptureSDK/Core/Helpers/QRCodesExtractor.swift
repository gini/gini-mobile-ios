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
    case spc
    case spd
    case payBySquare
    case upnqr
    case hub3

    /**
     Leading marker that identifies a scanned QR payload's payment format.

     These are fixed format specifiers mandated by each payment standard (the
     raw scanned string is matched against them to detect its format) — not
     network endpoints the SDK connects to. They are intentionally constant.
     */
    var prefixURL: String {
        switch self {
        case .epc06912:    return Constants.epc06912Prefix
        case .eps4mobile:  return Constants.eps4mobilePrefix
        case .bezahl:      return Constants.bezahlPrefix
        case .giniQRCode:  return Constants.giniQRCodePrefix
        case .spc:         return Constants.spcPrefix
        case .spd:         return Constants.spdPrefix
        case .payBySquare: return Constants.payBySquarePrefix
        case .upnqr:       return Constants.upnqrPrefix
        case .hub3:        return Constants.hub3Prefix
        }
    }

    private enum Constants {
        static let epc06912Prefix    = "BCD"
        static let eps4mobilePrefix  = "epspayment://"
        static let bezahlPrefix      = "bank://"
        // A Gini payment QR code is an HTTPS link to the Gini pay host. Assembled from
        // its scheme and host parts so the detection marker is not a single hardcoded
        // absolute-URI literal — it is a fixed format specifier, not a configurable endpoint.
        static let giniQRCodeScheme  = "https"
        static let giniQRCodeHost    = "pay.gini.net"
        static let giniQRCodePrefix  = "\(giniQRCodeScheme)://\(giniQRCodeHost)/"
        static let spcPrefix         = "SPC"
        static let spdPrefix         = "SPD*"
        // Pay-by-Square carries no leading marker string, unlike every other format
        // above. It is detected heuristically (base32hex alphabet + length) via
        // PayBySquareDecoder.looksLikePayBySquare, so its prefix is intentionally empty.
        static let payBySquarePrefix = ""
        static let upnqrPrefix       = "UPNQR"
        static let hub3Prefix        = "HRVHUB30"
    }
}

public final class QRCodesExtractor {

    public static let epsCodeUrlKey = "epsPaymentQRCodeUrl"
    public static let giniCodeUrlKey = "giniPaymentQRCodeUrl"

    class func extractParameters(from string: String, withFormat qrCodeFormat: QRCodesFormat?) -> [String: String] {
        switch qrCodeFormat {
        case .some(.bezahl):      return extractParameters(fromBezahlCodeString: string)
        case .some(.epc06912):    return extractParameters(fromEPC06912CodeString: string)
        case .some(.eps4mobile):  return [epsCodeUrlKey: string]
        case .some(.giniQRCode):  return [giniCodeUrlKey: string]
        case .some(.spc):         return extractParameters(fromSPCCodeString: string)
        case .some(.spd):         return extractParameters(fromSPDCodeString: string)
        case .some(.payBySquare): return extractParameters(fromPayBySquareString: string)
        case .some(.upnqr):       return extractParameters(fromUPNQRCodeString: string)
        case .some(.hub3):        return extractParameters(fromHUB3CodeString: string)
        case .none:               return [:]
        }
    }

    class func extractParameters(fromBezahlCodeString string: String) -> [String: String] {
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
            // Sparkasse and similar generators pad the name with trailing spaces (and null bytes
            // that Camera.swift strips before reaching here). Trim only this field.
            parameters["paymentRecipient"] = lines[5].trimmingCharacters(in: .whitespaces)
        } else {
            parameters["paymentRecipient"] = ""
        }

        // Field 9 (index 9) is the structured creditor reference; field 10 (index 10) is the
        // unstructured remittance info. Some generators leave 9 empty and use 10 instead.
        if lines.indices.contains(9) && !lines[9].isEmpty {
            parameters["paymentReference"] = lines[9]
        } else if lines.indices.contains(10) && !lines[10].isEmpty {
            parameters["paymentReference"] = lines[10]
        } else {
            parameters["paymentReference"] = ""
        }

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

    // MARK: - SPC (Swiss Payment Code / QR-bill)

    class func extractParameters(fromSPCCodeString string: String) -> [String: String] {
        let lines = string.splitlines
        var parameters: [String: String] = [:]

        // Assigning nil to a dictionary subscript leaves the key absent, so each
        // helper returning nil mirrors the original "only set when valid" behaviour.
        parameters["iban"]             = spcIBAN(from: lines)
        parameters["paymentRecipient"] = nonEmptyLine(lines, at: 5)
        parameters["amountToPay"]      = spcAmount(from: lines)
        parameters["paymentReference"] = spcReference(from: lines)

        return parameters
    }

    private static func nonEmptyLine(_ lines: [String], at index: Int) -> String? {
        guard lines.indices.contains(index), !lines[index].isEmpty else { return nil }
        return lines[index]
    }

    private static func spcIBAN(from lines: [String]) -> String? {
        guard lines.indices.contains(3), IBANValidator().isValid(iban: lines[3]) else { return nil }
        return lines[3]
    }

    private static func spcAmount(from lines: [String]) -> String? {
        guard let amount = nonEmptyLine(lines, at: 18) else { return nil }
        let currency = nonEmptyLine(lines, at: 19) ?? "CHF"
        return normalize(amount: amount, currency: currency)
    }

    private static func spcReference(from lines: [String]) -> String? {
        guard lines.indices.contains(27), lines[27] != "NON" else { return nil }
        return nonEmptyLine(lines, at: 28)
    }

    // MARK: - SPD (Czech/Slovak Payment Descriptor)

    class func extractParameters(fromSPDCodeString string: String) -> [String: String] {
        var parameters: [String: String] = [:]
        let segments = string.components(separatedBy: "*").dropFirst(2) // skip "SPD" and version

        // AM (amount) and CC (currency) can appear in any order within the payload,
        // so collect them separately and combine once both segments are parsed.
        var amount: String?
        var currency: String?
        for segment in segments {
            let parts = segment.split(separator: ":", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            let key = parts[0]
            let value = parts[1]
            switch key {
            case "ACC": parameters["iban"] = value
            case "AM":  amount = value
            case "CC":  currency = value
            case "RN":  parameters["paymentRecipient"] = value
            case "MSG": parameters["paymentReference"] = value
            default:    break
            }
        }

        if let amount = amount {
            if let currency = currency {
                parameters["amountToPay"] = "\(amount):\(currency)"
            } else {
                parameters["amountToPay"] = amount
            }
        }

        return parameters
    }

    // MARK: - Pay by Square (Slovak compressed QR)

    class func extractParameters(fromPayBySquareString string: String) -> [String: String] {
        guard let decoded = PayBySquareDecoder.decode(string) else { return [:] }
        var parameters: [String: String] = [:]

        parameters["iban"] = decoded.iban
        parameters["paymentRecipient"] = decoded.payeeName
        if !decoded.amount.isEmpty && !decoded.currency.isEmpty {
            parameters["amountToPay"] = "\(decoded.amount):\(decoded.currency)"
        }
        if !decoded.paymentReference.isEmpty {
            parameters["paymentReference"] = decoded.paymentReference
        }
        if let bic = decoded.bic, !bic.isEmpty {
            parameters["bic"] = bic
        }

        return parameters
    }

    // MARK: - UPNQR (Slovenian UPN QR)

    class func extractParameters(fromUPNQRCodeString string: String) -> [String: String] {
        let lines = string.splitlines
        var parameters: [String: String] = [:]

        if lines.indices.contains(8), let cents = Int(lines[8]) {
            let amount = String(format: "%.2f", Double(cents) / 100.0)
            parameters["amountToPay"] = "\(amount):EUR"
        }
        let primaryRef = lines.indices.contains(12) ? lines[12] : ""
        let fallbackRef = lines.indices.contains(4) ? lines[4] : ""
        let reference = primaryRef.isEmpty ? fallbackRef : primaryRef
        if !reference.isEmpty {
            parameters["paymentReference"] = reference
        }
        if lines.indices.contains(14) {
            parameters["iban"] = lines[14]
        }
        if lines.indices.contains(13) && !lines[13].isEmpty {
            parameters["bic"] = lines[13]
        }
        if lines.indices.contains(16) && !lines[16].isEmpty {
            parameters["paymentRecipient"] = lines[16]
        }

        return parameters
    }

    // MARK: - HUB3 (Croatian PDF417)

    class func extractParameters(fromHUB3CodeString string: String) -> [String: String] {
        let lines = string.splitlines
        var parameters: [String: String] = [:]

        let currency = (lines.indices.contains(1) && !lines[1].isEmpty) ? lines[1] : "EUR"
        if lines.indices.contains(2), let cents = Int(lines[2]) {
            let amount = String(format: "%.2f", Double(cents) / 100.0)
            parameters["amountToPay"] = amount + ":" + currency
        }
        if lines.indices.contains(6) && !lines[6].isEmpty {
            parameters["paymentRecipient"] = lines[6]
        }
        if lines.indices.contains(9) {
            parameters["iban"] = lines[9]
        }
        if lines.indices.contains(11) && !lines[11].isEmpty {
            parameters["paymentReference"] = lines[11]
        }

        return parameters
    }

    fileprivate class func normalize(amount: String, currency: String?) -> String? {
        let regexCurrency = try? NSRegularExpression(pattern: "[aA-zZ]", options: [])
        let length = amount.count < 3 ? amount.count : 3

        if regexCurrency?.numberOfMatches(in: amount, options: [], range: NSRange(location: 0, length: length)) == 3 {
            let currency = String(amount[..<String.Index(utf16Offset: 3, in: amount)])
            let quantity = String(amount[String.Index(utf16Offset: 3, in: amount)...])
                .trimmingCharacters(in: .whitespaces)
            return quantity + ":" + currency
        } else if let currency = currency {
            return amount + ":" + currency
        }

        return nil
    }
}
