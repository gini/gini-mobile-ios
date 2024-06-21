//
//  BankSelectionTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

final class BankSelectionTableViewCellModel {

    private var isSelected: Bool = false

    var shouldShowSelectionIcon: Bool {
        isSelected
    }

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark7,
                                             darkModeColor: UIColor.GiniMerchantColors.light7).uiColor()

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    var bankIconBorderColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark5,
                                        darkModeColor: UIColor.GiniMerchantColors.light5).uiColor()

    var bankName: String
    var bankNameLabelFont: UIFont
    let bankNameLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark1,
                                                      darkModeColor: UIColor.GiniMerchantColors.light1).uiColor()

    let selectedBankBorderColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.accent1,
                                                     darkModeColor: UIColor.GiniMerchantColors.accent1).uiColor()
    let notSelectedBankBorderColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark5,
                                                        darkModeColor: UIColor.GiniMerchantColors.light5).uiColor()
    
    let selectionIndicatorImage = UIImageNamedPreferred(named: "gm.selectionIndicator")

    init(paymentProvider: PaymentProviderAdditionalInfo) {
        self.isSelected = paymentProvider.isSelected
        self.bankImageIconData = paymentProvider.paymentProvider.iconData
        self.bankName = paymentProvider.paymentProvider.name

        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.bankNameLabelFont = GiniMerchantConfiguration.shared.textStyleFonts[.body1] ?? defaultRegularFont
    }
}
