//
//  Utilites.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Returns a decimal value

 - parameter inputFieldString: String from input field.

 - returns: decimal value in current locale.
 */

public func decimal(from inputFieldString: String) -> Decimal? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = ""
    return formatter.number(from: inputFieldString)?.decimalValue
}
