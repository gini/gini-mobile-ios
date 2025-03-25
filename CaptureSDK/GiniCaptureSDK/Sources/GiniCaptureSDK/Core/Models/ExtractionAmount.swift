//
//  ExtractionAmount.swift
//  
//
//  Created by David Vizaknai on 08.12.2022.
//

import Foundation
import GiniBankAPILibrary

public struct ExtractionAmount {
    public let value: Decimal
    public let currency: AmountCurrency

    public init(value: Decimal, currency: AmountCurrency) {
        self.value = value
        self.currency = currency
    }

    /// Formats the `ExtractionAmount` into a string representation.
    public func formattedString() -> String {
        let formattedValue = value.stringValue(withDecimalPoint: 2) ?? "\(value)"
        return "\(formattedValue):\(currency.rawValue)"
    }

    /// Extracts an `ExtractionAmount` from the given extractions dictionary.
    /// Returns `nil` if the extraction value is missing or invalid.
    public static func extract(from extractions: [String: Extraction]) -> ExtractionAmount? {
        guard let amountValue = extractions["amountToPay"]?.value,
              let amountComponents = amountValue.split(separator: ":").first,
              let value = Decimal(string: String(amountComponents)) else { return nil }
        return ExtractionAmount(value: value, currency: .EUR)
    }
}

public enum AmountCurrency: String {
    case EUR, GBP, USD, CHF
}
