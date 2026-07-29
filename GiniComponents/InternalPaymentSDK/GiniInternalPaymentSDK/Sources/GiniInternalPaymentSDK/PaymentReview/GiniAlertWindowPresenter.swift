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
        guard !isPresenting else { return }

        // Prefer the source VC's window scene; fall back to the foreground active scene
        // so the alert is still shown if the source VC isn't yet attached to a window
        // (e.g. during a transition).
        let windowScene = sourceViewController.view.window?.windowScene
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }

        guard let windowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .clear
        window.rootViewController = rootViewController
        window.windowLevel = .alert
        window.makeKeyAndVisible()
        alertWindow = window

        rootViewController.present(alertController, animated: true)
    }

    /**
     Tears down the alert window. Call this from the alert's action handler
     and from the host view controller's `viewDidDisappear`.
     */
    func dismiss() {
        guard let rootViewController = alertWindow?.rootViewController else {
            tearDown()
            return
        }
        if let presented = rootViewController.presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.tearDown()
            }
        } else {
            tearDown()
        }
    }

    private func tearDown() {
        let window = alertWindow
        alertWindow = nil
        DispatchQueue.main.async {
            window?.isHidden = true
            window?.rootViewController = nil
        }
    }
}
