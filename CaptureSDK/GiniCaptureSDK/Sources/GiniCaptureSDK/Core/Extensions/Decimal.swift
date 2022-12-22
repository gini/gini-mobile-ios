//
//  Decimal.swift
//  
//
//  Created by David Vizaknai on 14.12.2022.
//

import Foundation

public extension Decimal {
    /// This function is an extension to the Decimal type in Swift. It converts a Decimal value to a Double value, rounding the result to the specified number of decimal places.
    /// - Parameter decimalPoint: specifies the number of decimal places to which the result should be cut off
    /// - Returns: returns the double value with the specified decimal places
    /// - Note: internal only
    func convertToDouble(withDecimalPoint decimalPoint: Int) -> Double {
        let divisor = Double(truncating: pow(10.0, decimalPoint) as NSNumber)
        let doubleValue = Double(truncating: self as NSNumber)
        let doubleValueTruncated = (doubleValue * divisor).rounded(.towardZero) / divisor

        return doubleValueTruncated
    }
}
