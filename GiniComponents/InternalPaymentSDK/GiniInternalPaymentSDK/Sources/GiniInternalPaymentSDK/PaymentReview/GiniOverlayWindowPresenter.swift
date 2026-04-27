//
//  GiniOverlayWindowPresenter.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Combine
import UIKit

/**
 Manages a secondary UIWindow for presenting view controllers that must
 survive the main VC hierarchy's lifecycle changes (e.g., SwiftUI .sheet teardowns).
 */
final class GiniOverlayWindowPresenter {
    
    struct NotificationName {
        static let dismissOverlay = Notification.Name("GiniOverlayWindowPresenter.dismissOverlay")
    }
    
    private var overlayWindow: UIWindow?
    
    /// Whether a VC is currently being presented in the overlay window.
    var isPresenting: Bool {
        overlayWindow?.rootViewController?.presentedViewController != nil
    }
    
    /**
     Presents the given view controller in an overlay window.
     
     - Parameters:
     - viewController: The VC to present (e.g., ShareInvoiceBottomView).
     - sourceViewController: A VC from the main window, used to obtain the UIWindowScene.
     - animated: Whether to animate the presentation.
     */
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
    
    /**
     Programmatically dismisses the overlay content and tears down the window.
     
     - Parameters:
     - animated: Whether to animate the dismissal.
     - completion: Called after the window has been torn down.
     */
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
        /// Capture the current window and clear the reference synchronously
        /// to avoid tearing down a new window from a previously scheduled block.
        let window = overlayWindow
        overlayWindow = nil
        
        /// Defer to the next run loop to avoid EXC_BAD_ACCESS when UIKit
        /// is still in the middle of a dismissal transition.
        DispatchQueue.main.async {
            window?.isHidden = true
            window?.rootViewController = nil
        }
    }
}

/**
 A UIView subclass that passes touches through when nothing meaningful is hit.

 When no presented sheet is covering the screen, `hitTest` returns `nil` so that
 touch events fall through to the underlying main window instead of being silently
 consumed by the transparent overlay window.
 */
final class GiniPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView === self ? nil : hitView
    }
}

/**
 A transparent VC that serves as the rootViewController of the overlay window.
 Detects when the presented VC is dismissed (by close button or swipe) and
 calls the onDismiss callback to tear down the overlay window.
 */
private final class GiniPassthroughViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    private let onDismiss: () -> Void
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        registerToNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = GiniPassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    /// Handles interactive swipe-down dismissal.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss()
    }
    
    override var childForStatusBarStyle: UIViewController? {
        presentedViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        presentedViewController
    }
    
    // MARK: - Private methods
    
    private func registerToNotifications() {
        NotificationCenter.default.publisher(for: GiniOverlayWindowPresenter.NotificationName.dismissOverlay)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onDismiss()
            }.store(in: &cancellables)
    }
}
