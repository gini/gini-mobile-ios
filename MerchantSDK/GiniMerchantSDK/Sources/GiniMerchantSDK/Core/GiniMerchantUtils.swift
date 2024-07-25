//
//  GiniMerchantUtils.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
/**
  Returns the GiniMerchant bundle.
 
 */
public func giniMerchantBundle() -> Bundle {
    Bundle.module
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
        let bundle = giniMerchantBundle()

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

public struct Price {
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
    var extractionString: String {
        return "\(value):\(currencyCode.uppercased())"
    }
    
    // Currency symbol
    var currencySymbol: String? {
        return (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.currencySymbol,
                                                        value: currencyCode.uppercased())
    }
    
    // Formatted string with currency symbol
    public var string: String? {
        let result = (Price.stringWithoutSymbol(from: value) ?? "") + " " + (currencySymbol ?? "")
        return result.isEmpty ? nil : result
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

func giniMerchantBundleResource() -> Bundle {
    Bundle.resource
}

extension Foundation.Bundle {
    /**
     The resource bundle associated with the current module.
     - important: When `GiniMerchantSDK` is distributed via Swift Package Manager, it will be synthesized automatically in the name of `Bundle.module`.
     */
    static var resource: Bundle = {
        let moduleName = "GiniMerchantSDK"
        let bundleName = "\(moduleName)_\(moduleName)"
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: MerchantSDKBundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return Bundle(for: GiniMerchant.self)
    }()
}

private class MerchantSDKBundleFinder {}
