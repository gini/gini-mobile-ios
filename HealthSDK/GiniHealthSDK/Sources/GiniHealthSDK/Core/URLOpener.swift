//
//  URLOpener.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct URLOpener {
    private let application: URLOpenerProtocol

    public init(_ application: URLOpenerProtocol) {
        self.application = application
    }

    func openWebsite(url: URL, completion: ((Bool) -> Void)?) {
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: completion)
        } else {
            completion?(false)
        }
    }
}

public protocol URLOpenerProtocol {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: URLOpenerProtocol {}
