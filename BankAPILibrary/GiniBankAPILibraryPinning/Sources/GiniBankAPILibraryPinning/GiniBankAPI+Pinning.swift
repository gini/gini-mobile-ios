//
//  GiniBankAPI+Pinning.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import TrustKit
import GiniBankAPILibrary

public extension GiniBankAPI.Builder {
    init(client: Client,
                api: APIDomain = .default,
                pinningConfig: [String: Any],
                logLevel: LogLevel = .none) {
        self.init(client: client, api: api, userApi: .default, logLevel: logLevel, sessionDelegate: SessionDelegate())
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
