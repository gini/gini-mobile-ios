//
//  PaymentReviewV2ViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import GiniHealthAPILibrary
import UIKit
import SwiftUI

// TODO: Rename the class at the end of development to PaymentReviewViewController to replace the previous version.
public class PaymentReviewV2ViewController: UIHostingController<PaymentReviewContentView> {
    
    private let selectedPaymentProvider: PaymentProvider
    private let model: PaymentReviewModel
    private var isInfoBarHidden = true
    
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
    }
}


// MARK: - PaymentReviewViewModelDelegate methods
extension PaymentReviewV2ViewController: PaymentReviewViewModelDelegate {
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
}
