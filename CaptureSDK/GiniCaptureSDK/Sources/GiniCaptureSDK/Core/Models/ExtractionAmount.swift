//
//  ExtractionAmount.swift
//  
//
//  Created by David Vizaknai on 08.12.2022.
//

import Foundation

public struct ExtractionAmount {
    public let value: Decimal
    public let currency: AmountCurrency

    public init(value: Decimal, currency: AmountCurrency) {
        self.value = value
        self.currency = currency
    }
}

public enum AmountCurrency: String {
    case EUR, GBP, USD, CHF
}
