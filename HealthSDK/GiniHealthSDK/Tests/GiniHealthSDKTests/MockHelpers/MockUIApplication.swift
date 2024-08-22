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
        switch url.absoluteString {
        case "ginipay-bank://", "ginipay-ingdiba://":
            // In tests we "open" Gini-Test-Payment-Provider and ING-DiBa
            return true
        default:
            return canOpen
        }
    }
 
    #if compiler(>=6.0)
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?) {
        if canOpen {
            DispatchQueue.main.async {
                completion?(true)
            }
        }
    }
    #else
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        if canOpen {
            completion?(true)
        }
    }
    #endif
}
