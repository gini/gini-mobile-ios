//
//  PaymentReviewViewController.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//


import GiniHealthAPILibrary
import UIKit
import SwiftUI

/**
 Modes for displaying PaymentReview content in the UI.
 */
public enum DisplayMode: Int {
    /** Displays the payment review content in a bottom sheet. */
    case bottomSheet
    /** Displays the payment review content as a scrollable document collection. */
    case documentCollection
}

public final class PaymentReviewViewController: UIHostingController<PaymentReviewContentView> {

    private let overlayPresenter = GiniOverlayWindowPresenter()
    private let alertPresenter = GiniAlertWindowPresenter()
    // Stored so viewWillTransition can set isDismissingForRotation before dismissing the sheet.
    private let observableModel: PaymentReviewObservableModel

    public let model: PaymentReviewModel

    /**
     Creates a `PaymentReviewViewController` configured for the given model and payment provider.

     - Parameters:
       - viewModel: The `PaymentReviewModel` driving the payment review screen.
       - selectedPaymentProvider: The payment provider pre-selected for this review session.
     */
    public init(viewModel: PaymentReviewModel, selectedPaymentProvider _: PaymentProvider) {
        self.model = viewModel

        let observableModel = PaymentReviewObservableModel(model: model)
        self.observableModel = observableModel
        super.init(rootView: PaymentReviewContentView(viewModel: observableModel))
    }
    
    @MainActor
    @preconcurrency required dynamic init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        model.viewModelDelegate = self
        view.backgroundColor = model.displayMode == .bottomSheet ? .clear : model.configuration.mainViewBackgroundColor
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        guard model.displayMode == .documentCollection else { return }

        navigationItem.title = model.strings.paymentReviewScreenTitle

        guard model.showPaymentReviewCloseButton else { return }

        let closeImage = model.configuration.paymentReviewClose.withRenderingMode(.alwaysTemplate)
        let closeButton = UIBarButtonItem(image: closeImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(closeButtonTapped))
        closeButton.accessibilityLabel = model.strings.closeButtonAccessibilityLabel
        closeButton.accessibilityHint = model.strings.closeButtonAccessibilityHint
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func closeButtonTapped() {
        model.closePaymentReview()
    }
    
    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard model.displayMode == .documentCollection else { return }

        // `size` is the *incoming* size, not the current one — it must be used here rather than
        // relying on `UIDevice.isPortrait()`, which reflects the old orientation at this point in the transition.
        let isLandscape = size.width > size.height

        observableModel.isDismissingForRotation = true
        // Reset when the rotation animation completes so the flag can't get stuck `true`
        // if no field regains focus after the transition.
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.observableModel.isDismissingForRotation = false
        }

        // On iOS 16 the `.presentationCompactAdaptation(.fullScreenCover)` animation fires
        // the moment the size class changes — before SwiftUI's onChange and before a
        // snapshot-hiding approach can take effect. The only reliable fix is to dismiss
        // the sheet imperatively at the UIKit level here, before that animation starts.
        // On iOS 17+ SwiftUI's `onChange(of: giniLayout.isLandscape)` also runs, but
        // `showBottomSheet` is already false by then so it becomes a no-op.
        if isLandscape, let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: false)
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        overlayPresenter.dismiss(animated: false)
        alertPresenter.dismiss()
        model.viewDidDisappear()
    }
}


// MARK: - PaymentReviewViewModelDelegate methods
extension PaymentReviewViewController: PaymentReviewViewModelDelegate {
    func presentInstallAppBottomSheet(bottomSheet: UIViewController) {
        overlayPresenter.present(bottomSheet, from: self)
    }

    func createPaymentRequestAndOpenBankApp() {
        overlayPresenter.dismiss(animated: true)
        model.onResumePaymentAfterBankInstall?()
    }

    func presentShareInvoiceBottomSheet(bottomSheet: UIViewController) {
        overlayPresenter.present(bottomSheet, from: self)
    }

    func obtainPDFFromPaymentRequest(paymentRequestId: String) {
        model.delegate?.obtainPDFURLFromPaymentRequest(viewController: self,
                                                       paymentRequestId: paymentRequestId)
    }

    func presentBankSelectionBottomSheet(bottomSheet: UIViewController) {
        overlayPresenter.present(bottomSheet, from: self)
    }
    
    func dismissPaymentReview() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismissScreen()
        }
    }
    
    func presentErrorAlert(message: String) {
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: model.strings.alertOkButtonTitle,
                                     style: .default) { [weak self] _ in
            self?.alertPresenter.dismiss()
        }
        alertController.addAction(okAction)
        // preferredAction must be set after addAction
        alertController.preferredAction = okAction

        alertPresenter.present(alertController, from: self)
    }
    
    private func dismissScreen() {
        overlayPresenter.dismiss(animated: false)
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
}
