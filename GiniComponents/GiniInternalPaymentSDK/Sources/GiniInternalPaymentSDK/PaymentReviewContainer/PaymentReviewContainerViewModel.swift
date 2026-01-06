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

/// The view model for the Payment Review container view.
public final class PaymentReviewContainerViewModel {
    @Published var selectedPaymentProvider: PaymentProvider
    
    var onExtractionFetched: (() -> Void)?
    let configuration: PaymentReviewContainerConfiguration
    let strings: PaymentReviewContainerStrings
    let primaryButtonConfiguration: ButtonConfiguration
    let secondaryButtonConfiguration: ButtonConfiguration
    let defaultStyleInputFieldConfiguration: TextFieldConfiguration
    let errorStyleInputFieldConfiguration: TextFieldConfiguration
    let selectionStyleInputFieldConfiguration: TextFieldConfiguration
    let poweredByGiniViewModel: PoweredByGiniViewModel
    var dispayMode: DisplayMode = .bottomSheet
    var bankImageIcon: UIImage?

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
       - extractions: An optional array of `Extraction` objects representing fetched data.
       - paymentInfo: An optional `PaymentInfo` object containing details about the payment.
       - selectedPaymentProvider: The selected payment provider from the Gini Health API.
       - configuration: The configuration settings for the payment review container.
       - strings: The string resources for localizing the payment review UI.
       - primaryButtonConfiguration: Configuration for the primary button in the UI.
       - secondaryButtonConfiguration: Configuration for the secondary button in the UI.
       - defaultStyleInputFieldConfiguration: Configuration for default-styled input fields.
       - errorStyleInputFieldConfiguration: Configuration for input fields that display errors.
       - selectionStyleInputFieldConfiguration: Configuration for input fields with selection styles.
       - poweredByGiniConfiguration: Configuration settings for the "Powered by Gini" branding.
       - poweredByGiniStrings: The string resources for localizing "Powered by Gini" UI elements.
       - displayMode: The display mode indicating how the payment review interface should be presented.
       - clientConfiguration: The client's configuration used to display view details.
     */
    public init(extractions: [Extraction]?,
                paymentInfo: PaymentInfo?,
                selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider,
                configuration: PaymentReviewContainerConfiguration,
                strings: PaymentReviewContainerStrings,
                primaryButtonConfiguration: ButtonConfiguration,
                secondaryButtonConfiguration: ButtonConfiguration,
                defaultStyleInputFieldConfiguration: TextFieldConfiguration,
                errorStyleInputFieldConfiguration: TextFieldConfiguration,
                selectionStyleInputFieldConfiguration: TextFieldConfiguration,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                displayMode: DisplayMode,
                clientConfiguration: ClientConfiguration?) {
        self.extractions = extractions
        self.paymentInfo = paymentInfo
        self.selectedPaymentProvider = selectedPaymentProvider
        self.configuration = configuration
        self.strings = strings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.secondaryButtonConfiguration = secondaryButtonConfiguration
        self.defaultStyleInputFieldConfiguration = defaultStyleInputFieldConfiguration
        self.errorStyleInputFieldConfiguration = errorStyleInputFieldConfiguration
        self.selectionStyleInputFieldConfiguration = selectionStyleInputFieldConfiguration
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.dispayMode = displayMode
        self.bankImageIcon = selectedPaymentProvider.iconData.toImage
        self.clientConfiguration = clientConfiguration
    }
}
