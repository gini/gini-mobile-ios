//
//  PaymentReviewViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import GiniHealthAPILibrary
import UIKit
import SwiftUI

/// Modes for displaying PaymentReview content in the UI.
public enum DisplayMode {
    case bottomSheet
    case documentCollection
}

public class PaymentReviewViewController: UIHostingController<PaymentReviewContentView> {
    
    private let selectedPaymentProvider: PaymentProvider
    private var isInfoBarHidden = true
    
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
        view.backgroundColor = .clear
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        guard model.showPaymentReviewCloseButton,
              model.displayMode == .documentCollection else { return }
        
        let closeImage = model.configuration.paymentReviewClose
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
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        model.viewDidDisappear()
    }
}


// MARK: - PaymentReviewViewModelDelegate methods
extension PaymentReviewViewController: PaymentReviewViewModelDelegate {
    func presentInstallAppBottomSheet(bottomSheet: UIViewController) {
        giniTopMostViewController().present(bottomSheet, animated: true)
    }

    func createPaymentRequestAndOpenBankApp() {
        self.presentedViewController?.dismiss(animated: true)
    }

    func presentShareInvoiceBottomSheet(bottomSheet: BottomSheetViewController) {
        presentBottomSheet(viewController: bottomSheet)
    }

    func obtainPDFFromPaymentRequest(paymentRequestId: String) {
        model.delegate?.obtainPDFURLFromPaymentRequest(viewController: self,
                                                       paymentRequestId: paymentRequestId)
    }

    func presentBankSelectionBottomSheet(bottomSheet: UIViewController) {
        giniTopMostViewController().present(bottomSheet, animated: true)
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
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
}
