//
//  Decimal.swift
//  
//
//  Created by David Vizaknai on 14.12.2022.
//

import Foundation

public extension Decimal {
    /**
    The stringValue(withDecimalPoint:) method takes an integer parameter decimalPoint, which represents the number of decimal points to be included in the output string. The method returns an optional String value, which is nil if the Decimal value cannot be converted to a string.

    Parameter decimalPoint: An integer representing the number of decimal points required in the output string.
    Returns: An optional String value that represents the Decimal value as a string with the specified number of decimal points. If the Decimal value cannot be converted to a string, the method returns nil.
    */

    func stringValue(withDecimalPoint decimalPoint: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = decimalPoint
        numberFormatter.minimumFractionDigits = decimalPoint
        numberFormatter.locale = Locale(identifier: "en")
        numberFormatter.usesGroupingSeparator = false

        return numberFormatter.string(from: self as NSNumber)
    }
}
