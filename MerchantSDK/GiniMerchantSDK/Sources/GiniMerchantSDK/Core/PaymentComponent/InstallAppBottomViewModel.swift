//
//  InstallAppBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

protocol InstallAppBottomViewProtocol: AnyObject {
    func didTapOnContinue()
}

final class InstallAppBottomViewModel {
    
    let giniMerchantConfiguration = GiniMerchantConfiguration.shared
    
    var selectedPaymentProvider: PaymentProvider?
    // Payment provider colors
    var paymentProviderColors: ProviderColors?
    
    weak var viewDelegate: InstallAppBottomViewProtocol?

    let backgroundColor: UIColor = GiniColor.standard7.uiColor()
    let rectangleColor: UIColor = GiniColor.standard5.uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)

    var titleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.install.app.bottom.sheet.title",
                                                             comment: "Install App Bottom sheet title")
    let titleLabelAccentColor: UIColor = GiniColor.standard2.uiColor()
    var titleLabelFont: UIFont

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    var bankIconBorderColor = GiniColor.standard5.uiColor()

    // More information part
    let moreInformationLabelTextColor: UIColor = GiniColor.standard3.uiColor()
    let moreInformationAccentColor: UIColor = GiniColor.standard3.uiColor()
    var moreInformationLabelText: String {
        isBankInstalled ? 
        NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.install.app.bottom.sheet.tip.description",
                                         comment: "Text for tip information label").replacingOccurrences(of: bankToReplaceString,
                                                                                                         with: selectedPaymentProvider?.name ?? "") :
        NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.install.app.bottom.sheet.notes.description",
                                         comment: "Text for notes information label").replacingOccurrences(of: bankToReplaceString,
                                                                                                           with: selectedPaymentProvider?.name ?? "")
    }
    

    var moreInformationLabelFont: UIFont
    let moreInformationIcon: UIImage = GiniMerchantImage.info.preferredUIImage()
    
    // Pay invoice label
    let continueLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.install.app.bottom.sheet.continue.button.text",
                                                                     comment: "Title label used for the Continue button")
    
    var appStoreIcon: UIImage = GiniMerchantImage.appStore.preferredUIImage()
    let bankToReplaceString = "[BANK]"
    
    var isBankInstalled: Bool {
        selectedPaymentProvider?.appSchemeIOS.canOpenURLString() == true
    }

    init(selectedPaymentProvider: PaymentProvider?) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIconData = selectedPaymentProvider?.iconData
        self.paymentProviderColors = selectedPaymentProvider?.colors
        
        titleText = titleText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")

        self.titleLabelFont = giniMerchantConfiguration.font(for: .subtitle1)
        self.moreInformationLabelFont = giniMerchantConfiguration.font(for: .captions1)
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinue()
    }
}
