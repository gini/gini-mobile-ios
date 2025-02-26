//
//  ShareInvoiceBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

/// A protocol for handling actions from the Onboarding Share Invoice bottom view
public protocol ShareInvoiceBottomViewProtocol: AnyObject {
    func didTapOnContinueToShareInvoice(paymentRequestId: String)
}

struct SingleApp {
    var title: String
    var image: UIImage?
    var isMoreButton: Bool
}

/// The view model for the Share Invoice bottom view.
public final class ShareInvoiceBottomViewModel {
    let configuration: ShareInvoiceConfiguration
    let strings: ShareInvoiceStrings
    let primaryButtonConfiguration: ButtonConfiguration
    let poweredByGiniViewModel: PoweredByGiniViewModel

    var selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?
    var paymentProviderColors: GiniHealthAPILibrary.ProviderColors?
    
    /// A weak reference to the delegate conforming to `ShareInvoiceBottomViewProtocol`.
    public weak var viewDelegate: ShareInvoiceBottomViewProtocol?

    let bankToReplaceString = "[BANK]"
    let titleText: String
    let descriptionLabelText: String
    let bankImageIcon: Data
    let qrCodeData: Data
    let continueButtonText: String
    
    let paymentRequestId: String

    /// An optional identifier for the document ID being shared in order to pass it back to the delegates
    public var documentId: String?
    public var paymentInfo: PaymentInfo?

    var appsMocked: [SingleApp] = []

    var clientConfiguration: ClientConfiguration?
    var shouldShowBrandedView: Bool {
        clientConfiguration?.ingredientBrandType == .fullVisible
    }
    /**
     Initializes a new instance of `ShareInvoiceBottomViewModel`.

     - Parameters:
       - selectedPaymentProvider: The selected payment provider, if available.
       - configuration: Configuration settings for sharing the invoice.
       - strings: String resources for localizing the share invoice UI.
       - primaryButtonConfiguration: Configuration for the primary button in the UI.
       - poweredByGiniConfiguration: Configuration for the "Powered by Gini" branding.
       - poweredByGiniStrings: String resources for localizing "Powered by Gini" UI elements.
     */
    public init(selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?,
                configuration: ShareInvoiceConfiguration,
                strings: ShareInvoiceStrings,
                primaryButtonConfiguration: ButtonConfiguration,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                qrCodeData: Data,
                paymentInfo: PaymentInfo?,
                paymentRequestId: String,
                clientConfiguration: ClientConfiguration?) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIcon = selectedPaymentProvider?.iconData ?? Data()
        self.paymentProviderColors = selectedPaymentProvider?.colors
        self.configuration = configuration
        self.strings = strings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.qrCodeData = qrCodeData
        self.paymentInfo = paymentInfo
        self.paymentRequestId = paymentRequestId
        self.clientConfiguration = clientConfiguration

        titleText = strings.titleTextPattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        descriptionLabelText = strings.descriptionTextPattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        continueButtonText = strings.continueLabelText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinueToShareInvoice(paymentRequestId: paymentRequestId)
    }
}
