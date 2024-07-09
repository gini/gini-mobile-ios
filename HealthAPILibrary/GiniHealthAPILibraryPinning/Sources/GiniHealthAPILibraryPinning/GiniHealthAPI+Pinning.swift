//
//  GiniHealthAPI+Pinning.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import GiniHealthAPILibrary
import Foundation
//
//public extension GiniHealthAPI.Builder {
//    
//    /**
//     *  Creates a Gini Health API Library with certificate pinning configuration.
//     *
//     * - Parameter client:            The Gini Health API client credentials
//     * - Parameter api:               The Gini Health API that the library interacts with. `APIDomain.default` by default
//     * - Parameter userApi:           The Gini User API that the library interacts with. `UserDomain.default` by default
//     * - Parameter pinningConfig:     Configuration for certificate pinning. Format ["PinnedDomains" : ["PublicKeyHashes"]]
//     * - Parameter logLevel:          The log level. `LogLevel.none` by default.
//     */
//
//    init(client: Client,
//         api: APIDomain = .default,
//         userApi: UserDomain = .default,
//         pinningConfig: [String: [String]],
//         logLevel: LogLevel = .none) {
//        self.init(client: client, api: api, userApi: userApi, logLevel: logLevel, sessionDelegate: SessionDelegate())
//        
//        // Extract and set pinnedKeyHashes from the configuration
//         let allKeyHashes = pinningConfig.values.flatMap { $0 }
//         SSLPinningManager.shared.pinnedKeyHashes = allKeyHashes
//    }
//    
//    /**
//     * Creates a Gini Health API Library to be used with a transparent proxy and a custom api access token source and certificate pinning configuration.
//     *
//     * - Parameter customApiDomain:        A custom api domain string.
//     * - Parameter alternativeTokenSource: A protocol for using custom api access token
//     * - Parameter pinningConfig:     Configuration for certificate pinning. Format ["PinnedDomains" : ["PublicKeyHashes"]]
//     * - Parameter logLevel:               The log level. `LogLevel.none` by default.
//     */
//    init(customApiDomain: String,
//         alternativeTokenSource: AlternativeTokenSource,
//         pinningConfig: [String: [String]],
//         logLevel: LogLevel = .none) {
//        self.init(customApiDomain: customApiDomain, alternativeTokenSource: alternativeTokenSource, logLevel: logLevel, sessionDelegate: SessionDelegate())
//        
//        // Extract and set pinnedKeyHashes from the configuration
//         let allKeyHashes = pinningConfig.values.flatMap { $0 }
//         SSLPinningManager.shared.pinnedKeyHashes = allKeyHashes
//    }
//}
//
//class SessionDelegate: NSObject, URLSessionDelegate {
//    public func urlSession(_ session: URLSession,
//                    didReceive challenge: URLAuthenticationChallenge,
//                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        SSLPinningManager.shared.validate(challenge: challenge, completionHandler: completionHandler)
//    }
//}
