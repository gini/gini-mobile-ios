//
//  GiniSessionDelegate.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class GiniSessionDelegate: NSObject, URLSessionDelegate {
    private let pinningManager: SSLPinningManager
    
    package init(pinnedKeyHashes: [String]) {
        self.pinningManager = SSLPinningManager(pinnedKeyHashes: pinnedKeyHashes)
    }
    
    package func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        pinningManager.validate(challenge: challenge, completionHandler: completionHandler)
    }
}
