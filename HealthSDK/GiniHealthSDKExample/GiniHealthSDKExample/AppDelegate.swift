//
//  AppDelegate.swift
//  Example Swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniHealthSDK
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var coordinator: AppCoordinator!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        coordinator = AppCoordinator(window: window)
        coordinator.start()

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        if (url.host == "payment-requester") {
            coordinator.processBankUrl(url: url)
        } else {
            coordinator.processExternalDocument(withUrl: url, sourceApplication: options[.sourceApplication] as? String)
        }
        return true
    }

}

