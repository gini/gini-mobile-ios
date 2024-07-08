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
        
        if let pinnedDomains = pinningConfig[kTSKPinnedDomains] as? [String: Any] {
            var keys: [String] = []
            for domainConfig in pinnedDomains.values {
                if let domainConfig = domainConfig as? [String: Any],
                   let keyHashes = domainConfig[kTSKPublicKeyHashes] as? [String] {
                    keys.append(contentsOf: keyHashes)
                }
            }
            SSLPinningManager.shared.pinnedKeyHashes = keys
        }
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
//        TrustKit.initSharedInstance(withConfiguration: pinningConfig)
        
        // Extract and set pinnedKeyHashes from the configuration
        if let pinnedDomains = pinningConfig[kTSKPinnedDomains] as? [String: Any] {
            var keys: [String] = []
            for domainConfig in pinnedDomains.values {
                if let domainConfig = domainConfig as? [String: Any],
                   let keyHashes = domainConfig[kTSKPublicKeyHashes] as? [String] {
                    keys.append(contentsOf: keyHashes)
                }
            }
            SSLPinningManager.shared.pinnedKeyHashes = keys
        }
    }
}

class SessionDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        SSLPinningManager.shared.validate(challenge: challenge, completionHandler: completionHandler)
//        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
//            completionHandler(.performDefaultHandling, nil)
//        }
    }
}
