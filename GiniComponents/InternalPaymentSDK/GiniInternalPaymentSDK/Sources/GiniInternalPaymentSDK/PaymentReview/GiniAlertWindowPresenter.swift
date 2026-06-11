//
//  GiniAlertWindowPresenter.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Manages a dedicated UIWindow at `.alert` level for presenting UIAlertControllers.

 Presenting alerts on their own window keeps them outside any active sheet's
 presentation chain, so they survive the sheet being dismissed (e.g. on rotation).
 */
final class GiniAlertWindowPresenter {

    private var alertWindow: UIWindow?

    var isPresenting: Bool { alertWindow != nil }

    /**
     Presents an alert controller on a dedicated alert-level window.

     - Parameters:
       - alertController: The `UIAlertController` to present.
       - sourceViewController: A VC from the main window, used to obtain the `UIWindowScene`.
     */
    func present(_ alertController: UIAlertController,
                 from sourceViewController: UIViewController) {
        guard !isPresenting,
              let windowScene = sourceViewController.view.window?.windowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC
        window.windowLevel = .alert
        window.makeKeyAndVisible()
        alertWindow = window

        rootVC.present(alertController, animated: true)
    }

    /**
     Tears down the alert window. Call this from the alert's action handler
     and from the host view controller's `viewDidDisappear`.
     */
    func dismiss() {
        let window = alertWindow
        alertWindow = nil
        DispatchQueue.main.async {
            window?.isHidden = true
            window?.rootViewController = nil
        }
    }
}
