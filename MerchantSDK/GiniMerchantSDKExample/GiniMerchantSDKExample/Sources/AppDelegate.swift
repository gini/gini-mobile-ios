//
//  AppDelegate.swift
//
//
//  Created by Maxim Backevich on 18/06/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = AppCoordinator(window: window)
        coordinator.start()
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        if (url.host == "payment-requester") {
            coordinator.processBankUrl()
        } else {
            coordinator.processExternalDocument(withUrl: url, sourceApplication: options[.sourceApplication] as? String)
        }
        return true
    }
}

