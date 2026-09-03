//
//  GiniHealthUtils.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniInternalPaymentSDK
import GiniUtilites
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
    return UIImage(named: name, in: giniHealthBundleResource(), compatibleWith: nil)
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
 Returns a localized string resource preferably from the client's bundle.

 - parameter key:     The key to search for in the strings file.
 - parameter comment: The corresponding comment.

 - returns: String resource for the given key.
 */
func NSLocalizedStringPreferredFormat(_ key: String,
                                      fallbackKey: String = "",
                                      comment: String,
                                      isCustomizable: Bool = true) -> String {
    let communicationTone = GiniHealthConfiguration.shared.clientConfiguration?.communicationTone?.rawValue
    
    return GiniLocalized.string(key,
                                fallbackKey: fallbackKey,
                                comment: comment,
                                locale: GiniHealthConfiguration.shared.customLocalization?.rawValue,
                                bundle: giniHealthBundle(),
                                communicationTone: communicationTone)
}

/**
 Returns an optional `UIColor` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the UIColor from `GiniColors` asset catalog.
 
 - returns: color if found with name.
 */
func UIColorPreferred(named name: String) -> UIColor {
    if let mainBundleColor = UIColor(named: name,
                                     in: Bundle.main,
                                     compatibleWith: nil) {
        return mainBundleColor
    }

    if let color = UIColor(named: name,
                           in: giniHealthBundleResource(),
                           compatibleWith: nil) {
        return color
    } else {
        fatalError("The color named '\(name)' does not exist.")
    }
}

func giniHealthBundleResource() -> Bundle {
    Bundle.resource
}

extension Foundation.Bundle {
    /**
     The resource bundle associated with the current module.
     - important: When `GiniHealthSDK` is distributed via Swift Package Manager, it will be synthesized automatically in the name of `Bundle.module`.
     */
    static var resource: Bundle = {
        let moduleName = "GiniHealthSDK"
        let bundleName = "\(moduleName)_\(moduleName)"
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: HealthSDKBundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return Bundle(for: GiniHealth.self)
    }()
}

private class HealthSDKBundleFinder {}
