//
//  GiniSessionDelegate.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// A delegate for URLSession that implements SSL pinning using the provided SSLPinningManager.
class GiniSessionDelegate: NSObject, URLSessionDelegate {

    /// The manager responsible for validating SSL certificates.
    private let pinningManager: SSLPinningManager

    /// Initializes the GiniSessionDelegate with a given SSL pinning configuration.
    ///
    /// - Parameter pinningConfig: A dictionary containing the pinning configuration, typically mapping domain names to their expected certificate fingerprints.
    internal init(pinningConfig: [String: [String]]) {
        self.pinningManager = SSLPinningManager(pinningConfig: pinningConfig)
    }

    /// Handles the URLSession authentication challenge by delegating the validation to the pinning manager.
    ///
    /// - Parameters:
    ///   - session: The URLSession that received the challenge.
    ///   - challenge: The authentication challenge that needs to be handled.
    ///   - completionHandler: A completion handler that must be called with the disposition and credential to use for the challenge.
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        pinningManager.validate(challenge: challenge, completionHandler: completionHandler)
    }
}
