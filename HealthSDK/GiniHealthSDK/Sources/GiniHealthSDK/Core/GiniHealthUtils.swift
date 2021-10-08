//
//  GiniHealthUtils.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 15.04.21.
//

import UIKit
/**
  Returns the GiniHealth bundle.
 
 */
public func giniHealthBundle() -> Bundle {
    Bundle.module
}

/**
 Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the image file without file extension.
 
 - returns: Image if found with name.
 */
func UIImageNamedPreferred(named name: String) -> UIImage? {
    if let clientImage = UIImage(named: name) {
        return clientImage
    }
    return UIImage(named: name, in: giniHealthBundle(), compatibleWith: nil)
}

/**
 Returns a localized string resource preferably from the client's bundle.
 
 - parameter key:     The key to search for in the strings file.
 - parameter comment: The corresponding comment.
 
 - returns: String resource for the given key.
 */
func NSLocalizedStringPreferredFormat(_ key: String,
                                      fallbackKey: String = "",
                                      comment: String,
                                      isCustomizable: Bool = true) -> String {
    let clientString = NSLocalizedString(key, comment: comment)
    let fallbackClientString = NSLocalizedString(fallbackKey, comment: comment)
    let format: String
    if (clientString.lowercased() != key.lowercased() || fallbackClientString.lowercased() != fallbackKey.lowercased())
        && isCustomizable {
        format = clientString
    } else {
        let bundle = giniHealthBundle()

        var defaultFormat = NSLocalizedString(key, bundle: bundle, comment: comment)
        
        if defaultFormat.lowercased() == key.lowercased() {
            defaultFormat = NSLocalizedString(fallbackKey, bundle: bundle, comment: comment)
        }
        
        format = defaultFormat
    }
    
    return format
}

/**
 Returns a decimal value
 
 - parameter inputFieldString: String from input field.
 
 - returns: decimal value in current locale.
 */

func decimal(from inputFieldString: String) -> Decimal? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = ""
    return formatter.number(from: inputFieldString)?.decimalValue
}

/**
   A help price structure with decimal value and currency code, used in amout inpur field.
 */

struct Price {
    // Decimal value
    var value: Decimal
    // Currency code
    let currencyCode: String
    
    /**
     Returns a price structure with decimal value and  currency code from extraction string
     
     - parameter extractionString: extracted string
     */
    
    init(value: Decimal, currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }
  
    /**
     Returns a price structure with decimal value and  currency code from extraction string
     
     - parameter extractionString: extracted string
     */
    
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
    
    // Formatted string with currency code for sending to the Gini Health Api
    var extractionString: String {
        return "\(value):\(currencyCode.uppercased())"
    }
    
    // Currency symbol
    var currencySymbol: String? {
        return (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.currencySymbol,
                                                        value: currencyCode)
    }
    
    // Formatted string with currency symbol
    var string: String? {
        
        let result = (Price.stringWithoutSymbol(from: value) ?? "") + " " + (currencySymbol ?? "")
        
        if result.isEmpty { return nil }
        
        return result
    }
    // Formatted string without currency symbol
    var stringWithoutSymbol: String? {
        return Price.stringWithoutSymbol(from: value)
    }
    
    static func stringWithoutSymbol(from value: Decimal) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        let formattedString = formatter.string(from: NSDecimalNumber(decimal: value))
        let trimmedFormattedStringWithoutCurrency = formattedString?.trimmingCharacters(in: .whitespaces)
        return trimmedFormattedStringWithoutCurrency
    }
}
