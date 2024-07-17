//
//  AppDelegate.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
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

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let path = components.path,
              let params = components.queryItems else {
            print("❌ can't parse URL")
            return false
        }

        // Validate URL components
        guard components.host == "beaver-d97a1.web.app",
              path == "/payment-requester",
              params.first(where: { $0.name == "paymentRequestId" }) != nil else {
            print("❌ unsupported URL")
            return false
        }

        // Process URL
        coordinator.processBankUrl()
        print("✅ Successfully proceed with URL: \(incomingURL.absoluteString)")
        return true
    }
}

