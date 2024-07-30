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
    let strings: ShareInvoiceStrings
    let primaryButtonConfiguration: ButtonConfiguration
    let poweredByGiniViewModel: PoweredByGiniViewModel

    var selectedPaymentProvider: PaymentProvider?
    var paymentProviderColors: ProviderColors?
    
    weak var viewDelegate: ShareInvoiceBottomViewProtocol?
    
    let bankToReplaceString = "[BANK]"
    let titleText: String
    let descriptionLabelText: String
    let tipLabelText: String

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    
    var appsMocked: [SingleApp] = []

    init(selectedPaymentProvider: PaymentProvider?, 
         configuration: ShareInvoiceConfiguration,
         strings: ShareInvoiceStrings,
         primaryButtonConfiguration: ButtonConfiguration,
         poweredByGiniConfiguration: PoweredByGiniConfiguration,
         poweredByGiniStrings: PoweredByGiniStrings) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIconData = selectedPaymentProvider?.iconData
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
        viewDelegate?.didTapOnContinueToShareInvoice()
    }
}
