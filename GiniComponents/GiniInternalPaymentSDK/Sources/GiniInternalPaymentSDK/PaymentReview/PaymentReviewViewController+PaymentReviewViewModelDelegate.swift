//
//  PaymentReviewViewController+PaymentReviewViewModelDelegate.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension PaymentReviewViewController: PaymentReviewViewModelDelegate {
    func presentInstallAppBottomSheet(bottomSheet: BottomSheetViewController) {
        bottomSheet.minHeight = Constants.inputContainerHeight
        presentBottomSheet(viewController: bottomSheet)
    }

    func createPaymentRequestAndOpenBankApp() {
        self.presentedViewController?.dismiss(animated: true)
        if paymentInfoContainerView.inputFieldsHaveNoErrors() {
            createPaymentRequest()
        }
    }

    func presentShareInvoiceBottomSheet(bottomSheet: BottomSheetViewController) {
        bottomSheet.minHeight = Constants.inputContainerHeight
        presentBottomSheet(viewController: bottomSheet)
    }

    func obtainPDFFromPaymentRequest() {
        model.delegate?.obtainPDFURLFromPaymentRequest(paymentInfo: paymentInfoContainerView.obtainPaymentInfo(), viewController: self)
    }

    func presentBankSelectionBottomSheet(bottomSheet: BottomSheetViewController) {
        bottomSheet.minHeight = Constants.inputContainerHeight
        presentBottomSheet(viewController: bottomSheet)
    }
}
