//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
 A help price structure with decimal value and currency code, used in amout inpur field.
 */

public struct Price {
    // Decimal value
    public var value: Decimal {
        didSet {
            if value > Price.maxValue {
                value = Price.maxValue
            }
        }
    }
    // Currency code
    let currencyCode: String
    
    // Maximum allowed value
    private static let maxValue: Decimal = 99999.99

    /**
     Returns a price structure with decimal value and  currency code from extraction string

     - parameter extractionString: extracted string
     */

    public init(value: Decimal, currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }

    /**
     Returns a price structure with decimal value and  currency code from extraction string

     - parameter extractionString: extracted string
     */

    public init?(extractionString: String) {

        let components = extractionString.components(separatedBy: ":")

        guard components.count == 2 else { return nil }

        guard let decimal = Decimal(string: components.first ?? "", locale: Locale(identifier: "en")),
              let currencyCode = components.last?.lowercased() else {
            return nil
        }

        self.value = decimal
        self.currencyCode = currencyCode
    }

    // Formatted string with currency code for sending to the Gini Health Api
    public var extractionString: String {
        return "\(value):\(currencyCode.uppercased())"
    }

    // Currency symbol
    var currencySymbol: String? {
        return (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.currencySymbol,
                                                        value: currencyCode.uppercased())
    }

    // Formatted string with currency symbol
    public var string: String? {
        let result = (Price.stringWithoutSymbol(from: value) ?? "") + " " + (currencySymbol ?? "€")
        return result.isEmpty ? nil : result
    }

    // Formatted string without currency symbol
    public var stringWithoutSymbol: String? {
        return Price.stringWithoutSymbol(from: value)
    }

    public static func stringWithoutSymbol(from value: Decimal) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        let formattedString = formatter.string(from: NSDecimalNumber(decimal: value))
        let trimmedFormattedStringWithoutCurrency = formattedString?.trimmingCharacters(in: .whitespaces)
        return trimmedFormattedStringWithoutCurrency
    }
}
