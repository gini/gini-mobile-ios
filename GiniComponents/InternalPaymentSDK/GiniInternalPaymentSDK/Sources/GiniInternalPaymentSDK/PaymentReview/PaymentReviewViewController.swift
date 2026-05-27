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
    // Stored so viewWillTransition can set isDismissingForRotation before dismissing the sheet.
    private let observableModel: PaymentReviewObservableModel

    public let model: PaymentReviewModel

    /**
     Creates a `PaymentReviewViewController` configured for the given model and payment provider.

     - Parameters:
       - viewModel: The `PaymentReviewModel` driving the payment review screen.
       - selectedPaymentProvider: The payment provider pre-selected for this review session.
     */
    public init(viewModel: PaymentReviewModel, selectedPaymentProvider: PaymentProvider) {
        self.model = viewModel

        let observableModel = PaymentReviewObservableModel(model: model)
        self.observableModel = observableModel
        super.init(rootView: PaymentReviewContentView(viewModel: observableModel))
    }
    
    @MainActor
    @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        model.viewModelDelegate = self
        view.backgroundColor = model.displayMode == .bottomSheet ? .clear : model.configuration.mainViewBackgroundColor
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        guard model.showPaymentReviewCloseButton,
              model.displayMode == .documentCollection else { return }
        
        let closeImage = model.configuration.paymentReviewClose.withRenderingMode(.alwaysTemplate)
        let closeButton = UIBarButtonItem(image: closeImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(closeButtonTapped))
        
        closeButton.accessibilityLabel = model.strings.closeButtonAccessibilityLabel
        closeButton.accessibilityHint =  model.strings.closeButtonAccessibilityHint
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
        guard isLandscape, let presentedVC = presentedViewController else { return }

        // On iOS 16 the `.presentationCompactAdaptation(.fullScreenCover)` animation fires
        // the moment the size class changes — before SwiftUI's onChange and before a
        // snapshot-hiding approach can take effect. The only reliable fix is to dismiss
        // the sheet imperatively at the UIKit level here, before that animation starts.
        //
        // Setting isDismissingForRotation first ensures the sheet's onDismiss handler
        // does not call didTapClose (which would close the entire payment review).
        // SwiftUI reconciles showBottomSheet = false via the sheet's isPresented binding
        // when the UIKit dismiss fires the onDismiss callback.
        //
        // On iOS 17+ SwiftUI's onChange(of: giniLayout.isLandscape) also runs, but
        // showBottomSheet is already false by then so it becomes a no-op.
        observableModel.isDismissingForRotation = true
        presentedVC.dismiss(animated: false)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        overlayPresenter.dismiss(animated: false)
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
                                     style: .default)
        alertController.addAction(okAction)
        giniTopMostViewController().present(alertController, animated: true)
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
