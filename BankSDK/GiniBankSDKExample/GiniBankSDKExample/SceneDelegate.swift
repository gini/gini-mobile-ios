//
//  SceneDelegate.swift
//  GiniBankSDKExample
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankSDK

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let appScheme = "BankSDKExtension://"
    private let appGroupName = "group.bank.extension.test"
    private let imageUrlKey = "incomingURL"

    var window: UIWindow?
    var coordinator: AppCoordinator!

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        coordinator = AppCoordinator(window: window)
        coordinator.start()

        if !connectionOptions.urlContexts.isEmpty {
            handle(urlContexts: connectionOptions.urlContexts)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handle(urlContexts: URLContexts)
    }

    private func handle(urlContexts: Set<UIOpenURLContext>) {
        guard GiniBankConfiguration.shared.openWithEnabled else {
            coordinator?.displayOpenWithAlertView()
            return
        }

        for context in urlContexts {
            let url = context.url
            let sourceApplication = context.options.sourceApplication

            if url.absoluteString == appScheme {
                if let userDefaults = UserDefaults(suiteName: appGroupName),
                   let imageUrlString = userDefaults.value(forKey: imageUrlKey) as? String,
                   let imageUrl = URL(string: imageUrlString) {
                    coordinator.processExternalDocumentFromPhotos(withUrl: imageUrl,
                                                                  sourceApplication: sourceApplication)
                }
            } else {
                coordinator.processExternalDocument(withUrl: url,
                                                    sourceApplication: sourceApplication)
            }
        }
    }
}
