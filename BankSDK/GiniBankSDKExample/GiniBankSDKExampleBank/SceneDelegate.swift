//
//  SceneDelegate.swift
//  Bank
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appDelegate: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("Expected AppDelegate on UIApplication.shared.delegate")
        }
        return appDelegate
    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let paymentViewController = PaymentViewController.instantiate(with: appDelegate.apiLib)
        let navigationController = UINavigationController(rootViewController: paymentViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        if !connectionOptions.urlContexts.isEmpty {
            handle(urlContexts: connectionOptions.urlContexts)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handle(urlContexts: URLContexts)
    }

    private func handle(urlContexts: Set<UIOpenURLContext>) {
        guard let url = urlContexts.first?.url else { return }
        appDelegate.handle(url: url)
    }
}
