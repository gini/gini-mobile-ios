//
//  ContentViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

class ContentViewModel {

    var modalController: UIHostingController<AnyView>?

    func openModule() {
        var view = ModuleHostView(for: GiniBankSDKModel())
        modalController = UIHostingController(rootView: AnyView(view))
//        modalController?.modalTransitionStyle = .coverVertical
//        modalController?.modalPresentationStyle = .fullScreen

        view.bankSDKProtocolDelegate = self

        if let topViewController = UIApplication.shared.topViewController, let modalController {
            topViewController.present(modalController, animated: true)
        }
    }
}

extension ContentViewModel: GiniBankSDKDelegate {
    func captureAnalysisDidFinishWithResults() {
        modalController?.dismiss(animated: true)
    }
    

    func captureAnalysisDidFinishWithoutResults() {
        modalController?.dismiss(animated: true)
    }

    func captureCanceled() {
        modalController?.dismiss(animated: true)
    }
}

extension UIApplication {

    var topViewController: UIViewController? {
        var topViewController: UIViewController?

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topViewController = topController
        }
        return topViewController
    }

    private var keyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene) }
            .first?
            .windows
            .first { $0.isKeyWindow }
    }
}
