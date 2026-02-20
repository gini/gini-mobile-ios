//
//  PaymentReviewViewController+PaymentReviewViewModelDelegate.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension PaymentReviewViewController: PaymentReviewViewModelDelegate {
    func presentInstallAppBottomSheet(bottomSheet: UIViewController) {
        present(bottomSheet, animated: true)
    }

    func createPaymentRequestAndOpenBankApp() {
        self.presentedViewController?.dismiss(animated: true)
        if paymentInfoContainerView.inputFieldsHaveNoErrors() {
            createPaymentRequest()
        }
    }

    func presentShareInvoiceBottomSheet(bottomSheet: BottomSheetViewController) {
        presentBottomSheet(viewController: bottomSheet)
    }

    func obtainPDFFromPaymentRequest(paymentRequestId: String) {
        model.delegate?.obtainPDFURLFromPaymentRequest(viewController: self,
                                                       paymentRequestId: paymentRequestId)
    }

    func presentBankSelectionBottomSheet(bottomSheet: UIViewController) {
        present(bottomSheet, animated: true)
    }
}
