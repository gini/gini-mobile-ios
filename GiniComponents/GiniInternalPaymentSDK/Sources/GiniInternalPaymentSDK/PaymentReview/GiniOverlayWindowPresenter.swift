//
//  GiniOverlayWindowPresenter.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/// Manages a secondary UIWindow for presenting view controllers that must
/// survive the main VC hierarchy's lifecycle changes (e.g., SwiftUI .sheet teardowns).
final class GiniOverlayWindowPresenter {

    private var overlayWindow: UIWindow?

    /// Whether a VC is currently being presented in the overlay window.
    var isPresenting: Bool {
        overlayWindow?.rootViewController?.presentedViewController != nil
    }

    /// Presents the given view controller in an overlay window.
    ///
    /// - Parameters:
    ///   - viewController: The VC to present (e.g., ShareInvoiceBottomView).
    ///   - sourceViewController: A VC from the main window, used to obtain the UIWindowScene.
    ///   - animated: Whether to animate the presentation.
    func present(_ viewController: UIViewController,
                 from sourceViewController: UIViewController,
                 animated: Bool = true) {
        guard !isPresenting else { return }

        guard let windowScene = sourceViewController.view.window?.windowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = .normal + 1
        window.backgroundColor = .clear

        let rootVC = GiniPassthroughViewController { [weak self] in
            self?.tearDown()
        }
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        self.overlayWindow = window

        rootVC.present(viewController, animated: animated) {
            viewController.presentationController?.delegate = rootVC
        }
    }

    /// Programmatically dismisses the overlay content and tears down the window.
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let rootVC = overlayWindow?.rootViewController,
              let presented = rootVC.presentedViewController else {
            tearDown()
            completion?()
            return
        }
        presented.dismiss(animated: animated) { [weak self] in
            self?.tearDown()
            completion?()
        }
    }

    private func tearDown() {
        // Defer to the next run loop to avoid EXC_BAD_ACCESS when UIKit
        // is still in the middle of a dismissal transition.
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.isHidden = true
            self?.overlayWindow?.rootViewController = nil
            self?.overlayWindow = nil
        }
    }
}

/// A transparent VC that serves as the rootViewController of the overlay window.
/// Detects when the presented VC is dismissed (by close button or swipe) and
/// calls the onDismiss callback to tear down the overlay window.
private final class GiniPassthroughViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

    private let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if presentedViewController?.isBeingDismissed == true {
            onDismiss()
        }
    }

    // Handles close button: when the presented VC calls dismiss(animated:),
    // UIKit forwards it to the presenting VC (this VC).
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) { [weak self] in
            completion?()
            if self?.presentedViewController == nil {
                self?.onDismiss()
            }
        }
    }
    
    // Handles interactive swipe-down dismissal.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss()
    }

    override var childForStatusBarStyle: UIViewController? {
        presentedViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        presentedViewController
    }
}
