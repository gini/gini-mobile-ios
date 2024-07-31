//
//  PaymentReviewContainerViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniPaymentComponents
import GiniHealthAPILibrary

class PaymentReviewContainerViewModel {
    var onExtractionFetched: (() -> Void)?
    let selectedPaymentProvider: PaymentProvider
    let isAmountFieldEditable: Bool
    let configuration: PaymentReviewContainerConfiguration
    let strings: PaymentReviewContainerStrings
    let primaryButtonConfiguration: ButtonConfiguration
    let defaultStyleInputFieldConfiguration: TextFieldConfiguration
    let errorStyleInputFieldConfiguration: TextFieldConfiguration
    let selectionStyleInputFieldConfiguration: TextFieldConfiguration
    let poweredByGiniViewModel: PoweredByGiniViewModel

    public var extractions: [Extraction] {
        didSet {
            self.onExtractionFetched?()
        }
    }

    init(extractions: [Extraction],
         selectedPaymentProvider: PaymentProvider,
         configuration: PaymentReviewContainerConfiguration,
         strings: PaymentReviewContainerStrings,
         primaryButtonConfiguration: ButtonConfiguration,
         defaultStyleInputFieldConfiguration: TextFieldConfiguration,
         errorStyleInputFieldConfiguration: TextFieldConfiguration,
         selectionStyleInputFieldConfiguration: TextFieldConfiguration,
         poweredByGiniConfiguration: PoweredByGiniConfiguration,
         poweredByGiniStrings: PoweredByGiniStrings,
         isAmountFieldEditable: Bool) {
        self.extractions = extractions
        self.selectedPaymentProvider = selectedPaymentProvider
        self.isAmountFieldEditable = isAmountFieldEditable
        self.configuration = configuration
        self.strings = strings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.defaultStyleInputFieldConfiguration = defaultStyleInputFieldConfiguration
        self.errorStyleInputFieldConfiguration = errorStyleInputFieldConfiguration
        self.selectionStyleInputFieldConfiguration = selectionStyleInputFieldConfiguration
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
    }
}
