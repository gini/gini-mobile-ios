//
//  SceneDelegate.swift
//  GiniHealthSDKExample
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator!

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        #if DEBUG
        // Unit tests host the test code in-process; skip the whole app lifecycle.
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            window = UIWindow(windowScene: windowScene)
            window?.makeKeyAndVisible()
            return
        }
        // UI tests run the host app in a separate process without the XCTest env
        // var, so detect them via the launch arg the UI test target sets. Skip
        // Firebase (committed plist's API key is a dev placeholder that trips
        // `FIRInstallations.validateAPIKey:` on local sim) but keep the
        // coordinator running — tests need the real screens.
        let isUITest = CommandLine.arguments.contains("-StartFromCleanState")
        #else
        let isUITest = false
        #endif

        if !isUITest {
            FirebaseApp.configure()
        }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        coordinator = AppCoordinator(window: window)
        coordinator.start()

        for context in connectionOptions.urlContexts {
            handle(url: context.url, sourceApplication: context.options.sourceApplication)
        }
    }

    func scene(_ scene: UIScene,
               openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            handle(url: context.url, sourceApplication: context.options.sourceApplication)
        }
    }

    private func handle(url: URL,
                        sourceApplication: String?) {
        if url.host == "payment-requester" {
            coordinator.processBankUrl(url: url)
        } else {
            coordinator.processExternalDocument(withUrl: url, sourceApplication: sourceApplication)
        }
    }
}
