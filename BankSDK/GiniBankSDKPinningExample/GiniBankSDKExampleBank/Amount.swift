//
//  Amount.swift
//  GiniBankSDKExample
//
//  Created by Nadya Karaban on 16.02.22.
//

import Foundation
import GiniBankSDK

public struct Amount {
        
    public let value: Decimal
    public let currencyCode: String
    
    public init(value: Decimal, currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }
    
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
    
    var extractionString: String {
        return "\(value):\(currencyCode.uppercased())"
    }
    
    var currencySymbol: String? {
        return (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.currencySymbol,
                                                        value: currencyCode)
    }
    
    var string: String? {
        var sign = ""
        if (value < 0) {
            sign = "- "
        }
        
        let result = sign + (currencySymbol ?? "") + (stringWithoutSymbol(from: abs(value)) ?? "")
        
        if result.isEmpty { return nil }
        
        return result
    }
    
    var stringWithoutSymbol: String? {
        return stringWithoutSymbol(from: value)
    }
    
    public func stringWithoutSymbol(from value: Decimal) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter.string(from: NSDecimalNumber(decimal: value))
    }
}

extension Amount: Equatable {}

extension Amount {
    
    static func *(amount: Amount, int: Int) -> Amount {
        
        return Amount(value: amount.value * Decimal(int),
                     currencyCode: amount.currencyCode)
    }
    
    struct AmountCurrencyMismatchError: Error {}
    
    static func +(lhs: Amount, rhs: Amount) throws -> Amount {
        
        if lhs.currencyCode != rhs.currencyCode {
            throw AmountCurrencyMismatchError()
        }
        
        return Amount(value: lhs.value + rhs.value,
                     currencyCode: lhs.currencyCode)
    }
    
    static func -(lhs: Amount, rhs: Amount) throws -> Amount {
        
        if lhs.currencyCode != rhs.currencyCode {
            throw AmountCurrencyMismatchError()
        }
        
        return Amount(value: lhs.value - rhs.value,
                     currencyCode: lhs.currencyCode)
    }
    
    static func max(_ lhs: Amount, _ rhs: Amount) -> Amount {
        return lhs.value >= rhs.value ? lhs : rhs
    }
}


