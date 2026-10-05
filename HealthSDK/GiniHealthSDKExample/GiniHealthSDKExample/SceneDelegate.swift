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
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            window = UIWindow(windowScene: windowScene)
            window?.makeKeyAndVisible()
            return
        }
        #endif

        FirebaseApp.configure()
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        coordinator = AppCoordinator(window: window)
        coordinator.start()

        for context in connectionOptions.urlContexts {
            handle(url: context.url, sourceApplication: context.options.sourceApplication)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            handle(url: context.url, sourceApplication: context.options.sourceApplication)
        }
    }

    private func handle(url: URL, sourceApplication: String?) {
        if url.host == "payment-requester" {
            coordinator.processBankUrl(url: url)
        } else {
            coordinator.processExternalDocument(withUrl: url, sourceApplication: sourceApplication)
        }
    }
}
