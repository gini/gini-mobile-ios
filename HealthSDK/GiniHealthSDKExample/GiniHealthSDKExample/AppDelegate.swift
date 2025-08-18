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
        let firebaseInfoFileName = "GoogleService-Info"
        let apiKeyName = "firebaseApiKey"
        let firebaseInfoFileType = "plist"
        
        if let firebaseInfoFilePath = Bundle.main.path(forResource: firebaseInfoFileName,
                                                       ofType: firebaseInfoFileType),
           let firebaseOptions = FirebaseOptions(contentsOfFile: firebaseInfoFilePath),
           let firebaseApiKey = Bundle.main.object(forInfoDictionaryKey: apiKeyName) as? String {
            firebaseOptions.apiKey = firebaseApiKey
            FirebaseApp.configure(options: firebaseOptions)
        }
        
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

