//
//  PaymentReviewViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
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

public class PaymentReviewViewController: UIHostingController<PaymentReviewContentView> {
    
    private let selectedPaymentProvider: PaymentProvider
    private var isInfoBarHidden = true
    private let overlayPresenter = GiniOverlayWindowPresenter()
    
    public let model: PaymentReviewModel
    
    public init(viewModel: PaymentReviewModel, selectedPaymentProvider: PaymentProvider) {
        self.model = viewModel
        self.selectedPaymentProvider = selectedPaymentProvider
        self.isInfoBarHidden = viewModel.configuration.isInfoBarHidden
        
        let observableModel = PaymentReviewObservableModel(model: model)
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
        
        let closeImage = model.configuration.paymentReviewClose.withRenderingMode(.alwaysOriginal)
        let closeButton = UIBarButtonItem(image: closeImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(closeButtonTapped))
        
        closeButton.accessibilityLabel = model.strings.closeButtonAccessibilityLabel
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
        // UIDevice.isPortrait() reflects the old orientation at this point in the transition.
        let isLandscape = size.width > size.height
        guard isLandscape, let presentedVC = presentedViewController else { return }

        // iOS captures a snapshot of the current screen before the rotation animation
        // begins — SwiftUI's onChange fires too late to affect it. Hiding the entire
        // presentation container (not just the sheet's content view) ensures both the
        // sheet content and UIKit's dimming/backdrop overlay are invisible in the
        // snapshot. SwiftUI's onChange(of: giniLayout.isLandscape) still owns the
        // actual dismissal.
        presentedVC.presentationController?.containerView?.isHidden = true
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
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
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
