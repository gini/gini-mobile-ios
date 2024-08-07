//
//  URLOpener.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

// URLOpener helper structure for better testing of the open AppStore links functionality
public struct URLOpener {
    private let application: URLOpenerProtocol

    public init(_ application: URLOpenerProtocol) {
        self.application = application
    }
    
    /// Opens AppStore with the provided URL
    ///
    /// - Parameters:
    ///   - url: link that will be opened
    ///   - completion: called after opening is completed
    ///                 param is true if website was opened successfully
    ///                 param is false if opening failed

    public func openLink(url: URL, completion: ((Bool) -> Void)?) {
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: completion)
        } else {
            completion?(false)
        }
    }
    
    public func canOpenLink(url: URL) -> Bool {
        application.canOpenURL(url)
    }
}

public protocol URLOpenerProtocol {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: URLOpenerProtocol {}
