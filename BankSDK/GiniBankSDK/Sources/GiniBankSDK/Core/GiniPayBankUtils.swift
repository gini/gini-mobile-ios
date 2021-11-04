//
//  GiniPayBankUtils.swift
//  GiniPayBank
//
//  Created by Nadya Karaban on 24.02.21.
//

import GiniCapture
public protocol GiniPayBankAnalysisDelegate : AnalysisDelegate {}

/**
 Returns a localized string resource preferably from the client's bundle. Used in Return Assistant Screens.
 
 - parameter key:     The key to search for in the strings file.
 - parameter comment: The corresponding comment.
 
 - returns: String resource for the given key.
 */
func NSLocalizedStringPreferredGiniPayFormat(_ key: String,
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
        let bundle = giniPayBankBundle()
        var defaultFormat = NSLocalizedString(key, bundle: bundle, comment: comment)
        
        if defaultFormat.lowercased() == key.lowercased() {
            defaultFormat = NSLocalizedString(fallbackKey, bundle: bundle, comment: comment)
        }
        
        format = defaultFormat
    }
    
    return format
}

func giniPayBankBundle() -> Bundle {
    Bundle(for: GiniPayBank.self)
}

/**
 Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the image file without file extension.
 
 - returns: Image if found with name.
 */
func prefferedImage(named name: String) -> UIImage? {
    if let clientImage = UIImage(named: name) {
        return clientImage
    }
    let bundle = giniPayBankBundle()
    return UIImage(named: name, in: bundle, compatibleWith: nil)
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
public func receivePaymentRequestId(url: URL, completion: @escaping (Result<String, GiniPayBankError>) -> Void) {
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

    /**
     Returns the current version of the Gini Pay Bank SDK.
     If there is an error retrieving the version the returned value will be an empty string.
     */
public var versionString: String {
        return GiniPayBankVersion
    }
