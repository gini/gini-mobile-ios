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

    func obtainPDFFromPaymentRequest(paymentRequestId: String) {
        model.delegate?.obtainPDFURLFromPaymentRequest(viewController: self,
                                                       paymentRequestId: paymentRequestId)
    }

    func presentBankSelectionBottomSheet(bottomSheet: BottomSheetViewController) {
        print("GINI LOG: Content of \(self.presentingViewController) navigation controller \(self.presentingViewController?.navigationController?.viewControllers) \n")
        print("GINI LOG: Content of \(self) navigation controller \(self.navigationController?.viewControllers) \n")
        print("GINI LOG: Content of bottomSheet navigation controller \(bottomSheet.navigationController?.viewControllers) \n")
        bottomSheet.minHeight = Constants.inputContainerHeight
        presentBottomSheet(viewController: bottomSheet)
    }
}
