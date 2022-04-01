//
//  AppDelegate.swift
//  Bank
//
//  Created by Nadya Karaban on 30.04.21.
//

import GiniBankAPILibrary
import GiniBankSDK
import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var paymentRequestId: String = ""
    private let apiLib = GiniBankAPI.Builder(client: CredentialsManager.fetchClientFromBundle()).build()
    private var coordinator: PaymentCordinator!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        coordinator = PaymentCordinator(apiLib: apiLib)
        coordinator.start()
        window?.rootViewController = coordinator.rootViewController

        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        receivePaymentRequestId(url: url) { result in
            switch result {
            case let .success(requestId):
                self.paymentRequestId = requestId
                NotificationCenter.default.post(name: .appBecomeActive, object: nil)
            case .failure:
                break
            }
        }
        return true
    }
}
