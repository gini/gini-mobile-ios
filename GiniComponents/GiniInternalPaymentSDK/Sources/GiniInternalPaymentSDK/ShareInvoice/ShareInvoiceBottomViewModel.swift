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
    func didTapOnContinueToShareInvoice(documentId: String?)
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
    let tipLabelText: String
    let bankImageIcon: UIImage

    /// An optional identifier for the document ID being shared in order to pass it back to the delegates
    public var documentId: String?

    var appsMocked: [SingleApp] = []

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
         poweredByGiniStrings: PoweredByGiniStrings) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIcon = selectedPaymentProvider?.iconData.toImage ?? UIImage()
        self.paymentProviderColors = selectedPaymentProvider?.colors
        self.configuration = configuration
        self.strings = strings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)

        titleText = strings.titleTextPattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        descriptionLabelText = strings.descriptionTextPattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        tipLabelText = strings.tipLabelPattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")

        self.generateAppMockedElements()
    }
    
    private func generateAppMockedElements() {
        for _ in 0..<2 {
            self.appsMocked.append(SingleApp(title: strings.singleAppTitle, isMoreButton: false))
        }
        self.appsMocked.append(SingleApp(title: selectedPaymentProvider?.name ?? "", image: bankImageIcon, isMoreButton: false))
        self.appsMocked.append(SingleApp(title: strings.singleAppTitle, isMoreButton: false))
        self.appsMocked.append(SingleApp(title: strings.singleAppMore, image: configuration.moreIcon, isMoreButton: true))
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinueToShareInvoice(documentId: documentId)
    }
}
