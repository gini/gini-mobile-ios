//
//  AppDelegate.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit
import GiniBankSDK

@UIApplicationMain
    final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let appSheme = "BankSDKExtension://"
    private let appGroupName = "group.bank.extension.test"
    private let imageUrlKey = "incomingURL"
    var coordinator: AppCoordinator!
    var window: UIWindow?

    let currentLanguage = "de"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(currentLanguage, forKey: "AppleLanguage")
        Bundle.setLanguage(currentLanguage)
        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = AppCoordinator(window: window ?? UIWindow())
        coordinator.start()
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		guard GiniBankConfiguration.shared.openWithEnabled else {
			coordinator.displayOpenWithAlertView()
			return false
		}
        // Coming from Photos extension app
        if url.absoluteString == appSheme {
            if let userDefaults = UserDefaults(suiteName: appGroupName) {
                // Getting urlString for the image
                if let imageUrlString = userDefaults.value(forKey: imageUrlKey), let imageUrl = URL(string: imageUrlString as! String) {
                    coordinator.processExternalDocumentFromPhotos(withUrl: imageUrl, sourceApplication: options[.sourceApplication] as? String)
                }
            }
        } else {
            // Coming from Files share fun ctionality
                coordinator.processExternalDocument(withUrl: url, sourceApplication: options[.sourceApplication] as? String)
        }
        return true
    }
}

private var associatedBundle: Bundle?

extension Bundle {

    static let once: Void = {
        object_setClass(Bundle.main, LocalizedBundle.self)
    }()

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            associatedBundle = nil
            return
        }
        associatedBundle = bundle
        _ = Bundle.once
    }

    private class LocalizedBundle: Bundle {
        override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
            return associatedBundle?.localizedString(forKey: key, value: value, table: tableName)
            ?? super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}
