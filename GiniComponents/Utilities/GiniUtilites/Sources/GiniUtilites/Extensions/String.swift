//
//  String.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public extension String {
    func toColor() -> UIColor? {
        return UIColor(hex: "#\(self)FF")
    }

    func canOpenURLString() -> Bool {
        if let url = URL(string: self) , UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }

    /**
     Returns a decimal value

     - parameter inputFieldString: String from input field.

     - returns: decimal value in current locale.
     */
    
    func decimal() -> Decimal? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter.number(from: self)?.decimalValue
    }
    
    /**
     Converts a string representation of a monetary amount to a `Price` object.
     
     - Parameters:
       - maxDigitsLength: Maximum number of digits to process. Additional characters will be truncated.
       - currencyCode: Currency code (e.g., "EUR", "USD", "GBP" , "€"). Defaults to "€".
     
     - Returns: An optional `Price` object containing the decimal value and specified currency code,
                or `nil` if the string contains no valid digits or the conversion fails.
     
     # Example
    ```swift
     let priceString = "1,234.56"
     if let price = priceString.toPrice(maxDigitsLength: 10, currencyCode: "€") {
         print(price) // Price(value: 12.3456, currencyCode: "€")
     }
     
     let usdString = "$99.99"
     let usdPrice = usdString.toPrice(maxDigitsLength: 8, currencyCode: "USD")
     // Result: Price(value: 9.999, currencyCode: "USD")
    ```
     
     - Note: Input formats like "1,234.56", "1234.56", or "1.234,56" are all processed the same way,
             extracting only digits and dividing by 100.
     */
    func toPrice(maxDigitsLength: Int, currencyCode: String = "€") -> Price? {
        let onlyDigits = String(self
            .trimmingCharacters(in: .whitespaces)
            .filter { $0.isNumber }
            .prefix(maxDigitsLength))
        
        guard !onlyDigits.isEmpty,
              let decimal = Decimal(string: onlyDigits) else {
            return nil
        }
        
        let decimalWithFraction = decimal / 100
        return Price(value: decimalWithFraction, currencyCode: currencyCode)
    }
}
