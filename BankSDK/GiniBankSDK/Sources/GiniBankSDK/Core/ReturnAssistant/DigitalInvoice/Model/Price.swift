//
//  Price.swift
// GiniBank
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

struct Price {

    let value: Decimal
    let currencyCode: String

    init(value: Decimal, currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }

    init?(extractionString: String) {

        let components = extractionString.components(separatedBy: ":")

        guard components.count == 2 else { return nil }

        guard let decimal = Decimal(string: components.first ?? "", locale: Locale(identifier: "en")),
            let currencyCode = components.last?.lowercased() else {
                return nil
        }

        self.value = decimal
        self.currencyCode = currencyCode
    }

    var extractionString: String {
        return "\(value):\(currencyCode.uppercased())"
    }

    var currencySymbol: String? {
        return (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.currencySymbol,
                                                        value: currencyCode)
    }

    var string: String? {
        var sign = ""
        if value < 0 {
            sign = "- "
        }

        let result = sign + (currencySymbol ?? "") + (Price.stringWithoutSymbol(from: abs(value)) ?? "")

        if result.isEmpty { return nil }

        return result
    }

    var stringWithoutSymbol: String? {
        return Price.stringWithoutSymbol(from: value)
    }

    var localizedStringWithoutCurrencyCode: String? {
        return Price.localizedStringWithoutCurrencyCode(from: value)
    }

    var localizedStringWithCurrencyCode: String? {
        let formatter = NumberFormatter.twoDecimalPriceFormatter
        guard let formattedValue = formatter.string(from: NSDecimalNumber(decimal: value)) else { return nil }
        return "\(formattedValue) \(currencyCode.uppercased())"
    }

    static func stringWithoutSymbol(from value: Decimal) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter.string(from: NSDecimalNumber(decimal: value))?.trimmingCharacters(in: .whitespaces)
    }

    static func formatAmountString(newText: String) -> String? {
        let onlyDigits = String(newText.trimmingCharacters(in: .whitespaces)
            .filter { c in c != "," && c != "."}
            .prefix(7)
        )
        if let decimal = Decimal(string: onlyDigits) {
            let decimalWithFraction = decimal / 100
            return Price.stringWithoutSymbol(from: decimalWithFraction)?.trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    static func convertLocalizedStringToDecimal(_ priceString: String) -> Decimal? {
        let trimmedString = priceString.trimmingCharacters(in: .whitespaces)
        guard let number = NumberFormatter.twoDecimalPriceFormatter.number(from: trimmedString) else {
            return nil
        }
        return number.decimalValue
    }

    static func localizedStringWithoutCurrencyCode(from decimal: Decimal) -> String? {
        let formatter = NumberFormatter.twoDecimalPriceFormatter
        return formatter.string(from: NSDecimalNumber(decimal: decimal))
    }
}

extension Price: Equatable {}

extension Price {
    struct PriceCurrencyMismatchError: Error {}

    static func * (price: Price, int: Int) -> Price {
        return Price(value: price.value * Decimal(int),
                     currencyCode: price.currencyCode)
    }

    static func + (lhs: Price, rhs: Price) throws -> Price {
        if lhs.currencyCode != rhs.currencyCode {
            throw PriceCurrencyMismatchError()
        }

        return Price(value: lhs.value + rhs.value,
                     currencyCode: lhs.currencyCode)
    }

    static func - (lhs: Price, rhs: Price) throws -> Price {
        if lhs.currencyCode != rhs.currencyCode {
            throw PriceCurrencyMismatchError()
        }

        return Price(value: lhs.value - rhs.value,
                     currencyCode: lhs.currencyCode)
    }

    static func max(_ lhs: Price, _ rhs: Price) -> Price {
        return lhs.value >= rhs.value ? lhs : rhs
    }
}
