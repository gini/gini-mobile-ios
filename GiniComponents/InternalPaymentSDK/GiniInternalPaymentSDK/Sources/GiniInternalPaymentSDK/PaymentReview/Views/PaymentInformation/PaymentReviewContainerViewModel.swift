//
//  PaymentReviewContainerViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniUtilites
import UIKit

/**
Payment-related data passed to `PaymentReviewContainerViewModel`.
 */
public struct PaymentReviewContainerPaymentData {
    let extractions: [Extraction]?
    let document: Document?
    let paymentInfo: PaymentInfo?
    let selectedPaymentProvider: PaymentProvider
    let displayMode: DisplayMode

    public init(extractions: [Extraction]?,
                document: Document? = nil,
                paymentInfo: PaymentInfo?,
                selectedPaymentProvider: PaymentProvider,
                displayMode: DisplayMode) {
        self.extractions = extractions
        self.document = document
        self.paymentInfo = paymentInfo
        self.selectedPaymentProvider = selectedPaymentProvider
        self.displayMode = displayMode
    }
}

/**
 The view model for the Payment Review container view.
 */
public final class PaymentReviewContainerViewModel {
    
    let document: Document?
    let configuration: PaymentReviewContainerConfiguration
    let strings: PaymentReviewContainerStrings
    let primaryButtonConfiguration: ButtonConfiguration
    let secondaryButtonConfiguration: ButtonConfiguration
    let defaultStyleInputFieldConfiguration: TextFieldConfiguration
    let errorStyleInputFieldConfiguration: TextFieldConfiguration
    let selectionStyleInputFieldConfiguration: TextFieldConfiguration
    let poweredByGiniViewModel: PoweredByGiniViewModel
    
    var onExtractionFetched: (() -> Void)?
    var displayMode: DisplayMode = .bottomSheet
    var bankImageIcon: UIImage?
    
    @Published var selectedPaymentProvider: PaymentProvider

    /// An optional array of `Extraction` objects fetched during the payment review process. We use optional because we can rather have extractions fetched or payment information provided by user
    public var extractions: [Extraction]? {
        didSet {
            self.onExtractionFetched?()
        }
    }

    /// An optional `PaymentInfo` object containing details about the payment. We use optional because we can rather have extractions fetched or payment information provided by user
    public var paymentInfo: PaymentInfo? {
        didSet {
            self.onExtractionFetched?()
        }
    }
    
    var clientConfiguration: ClientConfiguration?
    var shouldShowBrandedView: Bool {
         clientConfiguration?.ingredientBrandType == .fullVisible
    }

    /**
     Initializes a new instance of `PaymentReviewContainerViewModel`.

     - Parameters:
       - paymentData: Groups the payment-related data (extractions, document, paymentInfo, selectedPaymentProvider, displayMode).
       - configuration: The configuration settings for the payment review container.
       - strings: The string resources for localizing the payment review UI.
       - buttonsConfiguration: Configuration for the primary and secondary buttons in the UI.
       - inputFieldsConfiguration: Configuration for the default, error, and selection styled input fields.
       - poweredByGiniViewModel: The view model for the "Powered by Gini" branding section.
       - clientConfiguration: The client's configuration used to display view details.
     */
    public init(paymentData: PaymentReviewContainerPaymentData,
                configuration: PaymentReviewContainerConfiguration,
                strings: PaymentReviewContainerStrings,
                buttonsConfiguration: PaymentReviewContainerButtonsConfiguration,
                inputFieldsConfiguration: PaymentReviewContainerInputFieldsConfiguration,
                poweredByGiniViewModel: PoweredByGiniViewModel,
                clientConfiguration: ClientConfiguration?) {
        self.extractions = paymentData.extractions
        self.paymentInfo = paymentData.paymentInfo
        self.document = paymentData.document
        self.selectedPaymentProvider = paymentData.selectedPaymentProvider
        self.configuration = configuration
        self.strings = strings
        self.primaryButtonConfiguration = buttonsConfiguration.primaryButton
        self.secondaryButtonConfiguration = buttonsConfiguration.secondaryButton
        self.defaultStyleInputFieldConfiguration = inputFieldsConfiguration.defaultStyle
        self.errorStyleInputFieldConfiguration = inputFieldsConfiguration.errorStyle
        self.selectionStyleInputFieldConfiguration = inputFieldsConfiguration.selectionStyle
        self.poweredByGiniViewModel = poweredByGiniViewModel
        self.displayMode = paymentData.displayMode
        self.bankImageIcon = paymentData.selectedPaymentProvider.iconData.toImage
        self.clientConfiguration = clientConfiguration
    }
}
