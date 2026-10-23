//
//  AppDelegate.swift
//  Bank
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import GiniBankSDK
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var paymentRequestId: String = ""
    let apiLib = GiniBankAPI.Builder(client: CredentialsManager.fetchClientFromBundle()).build()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Window and root view controller setup live in SceneDelegate.scene(_:willConnectTo:options:).
        return true
    }

    func handle(url: URL) {
        receivePaymentRequestId(url: url) { result in
            switch result {
            case let .success(requestId):
                self.paymentRequestId = requestId
            case .failure:
                break
            }
        }
    }
}
