//
//  ContentViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
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

    func captureRequestedSchedulePayment(result: AnalysisResult) {
        /// Simulate the host app opening its scheduled-transfer screen with the
        /// carried-over extractions — here we just print the count and dismiss,
        /// matching the ScreenAPICoordinator example flow.
        print("💻 Schedule payment requested with \(result.extractions.count) extractions")
        modalController?.dismiss(animated: true)
    }
}

extension UIApplication {

    var topViewController: UIViewController? {
        var viewController: UIViewController?

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            viewController = topController
        }
        return viewController
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
