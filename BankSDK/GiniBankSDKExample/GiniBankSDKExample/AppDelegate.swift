//
//  AppDelegate.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit

@UIApplicationMain
    final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let appsheme = "BankSDKExtension://"
    private let appGroupName = "group.bank.extension.test"
    private let imageUrlKey = "incomingURL"
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
        // Coming from Photos extension app
        if url.absoluteString == appsheme {
            if let userDefaults = UserDefaults(suiteName: appGroupName) {
                //Getting urlString for the image
                if let imageUrlString = userDefaults.value(forKey: imageUrlKey), let imageUrl = URL(string: imageUrlString as! String) {
                    coordinator.processExternalDocumentFromPhotos(withUrl: imageUrl, sourceApplication: options[.sourceApplication] as? String)
                }
            }
        } else {
            // Coming from Files share functionality
                coordinator.processExternalDocument(withUrl: url, sourceApplication: options[.sourceApplication] as? String)
        }
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        return UIInterfaceOrientationMask.portrait
    }
}

