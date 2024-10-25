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

public final class PaymentReviewContainerViewModel {
    var onExtractionFetched: (() -> Void)?
    var selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider
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

    public var extractions: [Extraction]? {
        didSet {
            self.onExtractionFetched?()
        }
    }

    public var paymentInfo: PaymentInfo? {
        didSet {
            self.onExtractionFetched?()
        }
    }

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
                displayMode: DisplayMode) {
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
    }
}
