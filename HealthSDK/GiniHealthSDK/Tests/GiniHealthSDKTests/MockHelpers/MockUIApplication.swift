//
//  MockUIApplication.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
@testable import GiniHealthSDK

struct MockUIApplication: URLOpenerProtocol {
    var canOpen: Bool
 
    func canOpenURL(_ url: URL) -> Bool {
        return canOpen
    }
 
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        if canOpen {
            completion?(true)
        }
    }
}
