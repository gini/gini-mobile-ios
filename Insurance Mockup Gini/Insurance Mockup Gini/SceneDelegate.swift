//
//  SceneDelegate.swift
//   Gini
//
//  Created by David Vizaknai on 21.03.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let appWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
        appWindow.windowScene = windowScene

        coordinator = AppCoordinator(window: appWindow)
        coordinator.start()

        window = appWindow
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        var paymentRequestID: String?
        for context in URLContexts {
            paymentRequestID = getPaymentRequestIdParameter(url: context.url.absoluteString)
        }
        guard let id = paymentRequestID else { return }
        coordinator.openInvoiceDetail(with: id)
    }

    private func getPaymentRequestIdParameter(url: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == "paymentRequestId" })?.value
    }
}
