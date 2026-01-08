//
//  GiniSessionDelegate.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class GiniSessionDelegate: NSObject, URLSessionDelegate {
    private let pinningManager: SSLPinningManager

    internal init(pinningConfig: [String: [String]]) {
        self.pinningManager = SSLPinningManager(pinningConfig: pinningConfig)
    }

    func urlSession(didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        pinningManager.validate(challenge: challenge, completionHandler: completionHandler)
    }
}
