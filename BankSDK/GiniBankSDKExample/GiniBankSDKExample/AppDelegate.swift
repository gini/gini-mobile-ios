//
//  AppDelegate.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

var coordinator: AppCoordinator!
var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = AppCoordinator(window: window ?? UIWindow())
        coordinator.start()

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        coordinator.processExternalDocument(withUrl: url, sourceApplication: options[.sourceApplication] as? String)
        return true
    }


}

