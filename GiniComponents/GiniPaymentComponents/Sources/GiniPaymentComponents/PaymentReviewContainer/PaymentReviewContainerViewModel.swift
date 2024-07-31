//
//  PaymentReviewContainerViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary

public final class PaymentReviewContainerViewModel {
    var onExtractionFetched: (() -> Void)?
    let selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider
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

    public init(extractions: [Extraction],
         selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider,
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
