//
//  PaymentReviewContainerViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

class PaymentReviewContainerViewModel {
    var onExtractionFetched: (() -> Void)?
    let selectedPaymentProvider: PaymentProvider
    let isAmountFieldEditable: Bool

    // Pay invoice label
    let payInvoiceLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.banking.app.button.label",
                                                                       comment: "Title label used for the pay invoice button")

    public var extractions: [Extraction] {
        didSet {
            self.onExtractionFetched?()
        }
    }

    init(extractions: [Extraction], selectedPaymentProvider: PaymentProvider, isAmountFieldEditable: Bool) {
        self.extractions = extractions
        self.selectedPaymentProvider = selectedPaymentProvider
        self.isAmountFieldEditable = isAmountFieldEditable
    }
}
