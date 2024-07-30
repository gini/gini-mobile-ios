//
//  ShareInvoiceBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniPaymentComponents
import GiniHealthAPILibrary

protocol ShareInvoiceBottomViewProtocol: AnyObject {
    func didTapOnContinueToShareInvoice()
}

struct SingleApp {
    var title: String
    var image: UIImage?
    var isMoreButton: Bool
}

final class ShareInvoiceBottomViewModel {
    let configuration: ShareInvoiceConfiguration
    let primaryButtonConfiguration: ButtonConfiguration
    let poweredByGiniViewModel: PoweredByGiniViewModel

    var selectedPaymentProvider: PaymentProvider?
    // Payment provider colors
    var paymentProviderColors: ProviderColors?
    
    weak var viewDelegate: ShareInvoiceBottomViewProtocol?
    
    // Title label
    var titleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.title",
                                                             comment: "Share Invoice Bottom sheet title")
    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }

    var descriptionLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.description",
                                                                        comment: "Text description for share bottom sheet")
    var tipLabelText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.tip.description",
                                                        comment: "Text for tip label")
    let tipActionablePartText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.tip.underlined.part",
                                                                 comment: "Text for tip actionable part from the label")
    let continueLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.continue.button.text",
                                                                     comment: "Title label used for the Continue button")
    let bankToReplaceString = "[BANK]"
    
    var appsMocked: [SingleApp] = []

    init(selectedPaymentProvider: PaymentProvider?, 
         configuration: ShareInvoiceConfiguration,
         primaryButtonConfiguration: ButtonConfiguration,
         poweredByGiniConfiguration: PoweredByGiniConfiguration) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIconData = selectedPaymentProvider?.iconData
        self.paymentProviderColors = selectedPaymentProvider?.colors
        self.configuration = configuration
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration)

        titleText = titleText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        descriptionLabelText = descriptionLabelText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        tipLabelText = tipLabelText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        
        self.generateAppMockedElements()
    }
    
    private func generateAppMockedElements() {
        for _ in 0..<2 {
            self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.app", comment: ""), isMoreButton: false))
        }
        self.appsMocked.append(SingleApp(title: selectedPaymentProvider?.name ?? "", image: bankImageIcon, isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.app", comment: ""), isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.more", comment: ""), image: configuration.moreIcon, isMoreButton: true))
        
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinueToShareInvoice()
    }
}
