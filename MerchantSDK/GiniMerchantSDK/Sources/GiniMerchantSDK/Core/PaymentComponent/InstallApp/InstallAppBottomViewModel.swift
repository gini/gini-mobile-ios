//
//  InstallAppBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniPaymentComponents
import GiniHealthAPILibrary

protocol InstallAppBottomViewProtocol: AnyObject {
    func didTapOnContinue()
}

final class InstallAppBottomViewModel {
    let primaryButtonConfiguration: ButtonConfiguration
    let configuration: InstallAppConfiguration
    let poweredByGiniViewModel: PoweredByGiniViewModel

    var selectedPaymentProvider: PaymentProvider?
    // Payment provider colors
    var paymentProviderColors: ProviderColors?
    
    weak var viewDelegate: InstallAppBottomViewProtocol?

    var titleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.title",
                                                             comment: "Install App Bottom sheet title")

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }

    var moreInformationLabelText: String {
        isBankInstalled ? 
        NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.tip.description",
                                         comment: "Text for tip information label").replacingOccurrences(of: bankToReplaceString,
                                                                                                         with: selectedPaymentProvider?.name ?? "") :
        NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.notes.description",
                                         comment: "Text for notes information label").replacingOccurrences(of: bankToReplaceString,
                                                                                                           with: selectedPaymentProvider?.name ?? "")
    }

    let continueLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.continue.button.text",
                                                                     comment: "Title label used for the Continue button")
    let bankToReplaceString = "[BANK]"
    
    var isBankInstalled: Bool {
        selectedPaymentProvider?.appSchemeIOS.canOpenURLString() == true
    }

    init(selectedPaymentProvider: PaymentProvider?,
         installAppConfiguration: InstallAppConfiguration,
         primaryButtonConfiguration: ButtonConfiguration,
         poweredByGiniConfiguration: PoweredByGiniConfiguration) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIconData = selectedPaymentProvider?.iconData
        self.paymentProviderColors = selectedPaymentProvider?.colors
        self.configuration = installAppConfiguration
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration)
        
        titleText = titleText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinue()
    }
}
