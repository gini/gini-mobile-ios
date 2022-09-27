//
//  GiniHealthAPI+Pinning.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import TrustKit
import GiniHealthAPILibrary

public extension GiniHealthAPI.Builder {
    
    /**
     *  Creates a Gini Health API Library with certificate pinning configuration.
     *
     * - Parameter client:            The Gini Health API client credentials
     * - Parameter api:               The Gini Health API that the library interacts with. `APIDomain.default` by default
     * - Parameter userApi:           The Gini User API that the library interacts with. `UserDomain.default` by default
     * - Parameter pinningConfig:     Configuration for certificate pinning.
     * - Parameter logLevel:          The log level. `LogLevel.none` by default.
     */

    init(client: Client,
         api: APIDomain = .default,
         userApi: UserDomain = .default,
         pinningConfig: [String: Any],
         logLevel: LogLevel = .none) {
        self.init(client: client, api: api, userApi: userApi, logLevel: logLevel, sessionDelegate: SessionDelegate())
        TrustKit.initSharedInstance(withConfiguration: pinningConfig)
    }
    
    /**
     * Creates a Gini Health API Library to be used with a transparent proxy and a custom api access token source and certificate pinning configuration.
     *
     * - Parameter customApiDomain:        A custom api domain string.
     * - Parameter alternativeTokenSource: A protocol for using custom api access token
     * - Parameter pinningConfig:          Configuration for certificate pinning.
     * - Parameter logLevel:               The log level. `LogLevel.none` by default.
     */
    init(customApiDomain: String,
         alternativeTokenSource: AlternativeTokenSource,
         pinningConfig: [String: Any],
         logLevel: LogLevel = .none) {
        self.init(customApiDomain: customApiDomain, alternativeTokenSource: alternativeTokenSource, logLevel: logLevel, sessionDelegate: SessionDelegate())
        TrustKit.initSharedInstance(withConfiguration: pinningConfig)
    }
}

class SessionDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
