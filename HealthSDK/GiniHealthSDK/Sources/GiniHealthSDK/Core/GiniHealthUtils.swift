//
//  GiniHealthUtils.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
/**
  Returns the GiniHealth bundle.

 */
public func giniHealthBundle() -> Bundle {
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
        let bundle = giniHealthBundleResource()

        var defaultFormat = NSLocalizedString(key, bundle: bundle, comment: comment)

        if defaultFormat.lowercased() == key.lowercased() {
            defaultFormat = NSLocalizedString(fallbackKey, bundle: bundle, comment: comment)
        }

        format = defaultFormat
    }

    return format
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
