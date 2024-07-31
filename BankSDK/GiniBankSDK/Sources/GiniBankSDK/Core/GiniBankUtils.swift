//
//  GiniBankUtils.swift
//  GiniBank
//
//  Created by Nadya Karaban on 24.02.21.
//

import GiniCaptureSDK
import Foundation
import UIKit
public protocol GiniBankAnalysisDelegate: AnalysisDelegate {}

/**
 Returns a localized string resource preferably from the client's bundle. Used in Return Assistant Screens.
 
 - parameter key:     The key to search for in the strings file.
 - parameter comment: The corresponding comment.
 
 - returns: String resource for the given key.
 */
func NSLocalizedStringPreferredGiniBankFormat(_ key: String,
                                              fallbackKey: String = "",
                                              comment: String,
                                              isCustomizable: Bool = true) -> String {
     if isCustomizable {
         if let clientLocalizedStringMainBundle = clientLocalizedString(key,
                                                                        fallbackKey: fallbackKey,
                                                                        comment: comment,
                                                                        bundle: .main) {
             return clientLocalizedStringMainBundle

         } else if let customBundle = GiniBankConfiguration.shared.customResourceBundle,
                   let clientLocalizedStringCustomBundle = clientLocalizedString(key,
                                                                                 fallbackKey: fallbackKey,
                                                                                 comment: comment,
                                                                                 bundle: customBundle) {
             return clientLocalizedStringCustomBundle
         }
     }
     return giniLocalizedString(key, fallbackKey: fallbackKey, comment: comment)
 }

private func clientLocalizedString(_ key: String,
                                   fallbackKey: String,
                                   comment: String,
                                   bundle: Bundle) -> String? {
    var clientString = NSLocalizedString(key,
                                         bundle: bundle,
                                         comment: comment)
    var fallbackClientString = NSLocalizedString(fallbackKey,
                                                 bundle: bundle,
                                                 comment: comment)
    
    if let localizedResourceName = GiniBankConfiguration.shared.localizedStringsTableName {
        clientString = NSLocalizedString(key,
                                         tableName: localizedResourceName,
                                         bundle: bundle,
                                         comment: comment)
        fallbackClientString = NSLocalizedString(fallbackKey,
                                                 tableName: localizedResourceName,
                                                 bundle: bundle,
                                                 comment: comment)
    }
    
    guard (clientString.lowercased() != key.lowercased() || fallbackClientString.lowercased() != fallbackKey.lowercased()) else {
        return nil
    }
    
    return clientString
}

private func giniLocalizedString(_ key: String,
                                 fallbackKey: String,
                                 comment: String) -> String {
    let giniBundle = giniBankBundle()
    
    var defaultFormat = NSLocalizedString(key,
                                          bundle: giniBundle,
                                          comment: comment)
    
    if defaultFormat.lowercased() == key.lowercased() {
        defaultFormat = NSLocalizedString(fallbackKey,
                                          bundle: giniBundle,
                                          comment: comment)
    }
    
    return defaultFormat
}

func giniBankBundle() -> Bundle {
    Bundle.resource
}

/**
 Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the image file without file extension.
 
 - returns: Image if found with name.
 */
func prefferedImage(named name: String) -> UIImage? {
    if let mainBundleImage = UIImage(named: name,
                                     in: Bundle.main,
                                     compatibleWith: nil) {
        return mainBundleImage
    }
    if let customBundle = GiniBankConfiguration.shared.customResourceBundle,
       let customBundleImage = UIImage(named: name,
                                       in: customBundle,
                                       compatibleWith: nil) {
        return customBundleImage
    }

    return UIImage(named: name,
                   in: giniBankBundle(),
                   compatibleWith: nil)
}
/**
 Returns an optional `UIColor` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the UIColor from `GiniColors` asset catalog.
 
 - returns: UIColor if found with name.
 */
func prefferedColor(named name: String) -> UIColor {
    if let mainBundleColor = UIColor(named: name,
                                     in: Bundle.main,
                                     compatibleWith: nil) {
        return mainBundleColor
    }

    if let customBundle = GiniBankConfiguration.shared.customResourceBundle,
       let customBundleColor = UIColor(named: name,
                                       in: customBundle,
                                       compatibleWith: nil) {
        return customBundleColor
    }

    if let color = UIColor(named: name,
                           in: giniBankBundle(),
                           compatibleWith: nil) {
        return color
    } else {
        fatalError("The color named '\(name)' does not exist.")
    }
}

/**
 Returns an optional `UIColor` instance with the given `name` preferably from the client's custom resources provider.

 - parameter name: The name of the UIColor.

 - returns: UIColor if found with name.
 */

public func prefferedColorByProvider(named name: String) -> UIColor {
    if let customProvider = GiniBankConfiguration.shared.customResourceProvider {
        return customProvider.customPrefferedColor(name: name)
    }
    return prefferedColor(named: name)
}

/**
 Getting the payment request id from incoming url
 Should be called inside function:
 func application(_ application: UIApplication,
                  open url: URL,
                  options: [UIApplicationOpenURLOptionsKey : Any] = [:] ) -> Bool
 
 - parameter url: The incoming url from the business app
 - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
 In success case it includes payment request Id.
 In case of failure error that there is no requestId in incoming url from the business app.
 
 */
public func receivePaymentRequestId(url: URL, completion: @escaping (Result<String, GiniBankError>) -> Void) {
    // Process the URL.
    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
        let params = components.queryItems else {
        completion(.failure(.noRequestId))
        return
    }

    if let requestId = params.first(where: { $0.name == "id" })?.value {
        completion(.success(requestId))
        print("requestID = \(requestId)")
    } else {
        completion(.failure(.noRequestId))
        print("Request id is missing")
    }

}

private class BankSDKBundleFinder {}

extension Foundation.Bundle {

    /**
     The resource bundle associated with the current module.
     - important: When `GiniBankSDK` is distributed via Swift Package Manager, it will be synthesized automatically in the name of `Bundle.module`.
     */
    static var resource: Bundle = {
        let moduleName = "GiniBankSDK"
        let bundleName = "\(moduleName)_\(moduleName)"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BankSDKBundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return Bundle(for: GiniBank.self)
    }()
}
