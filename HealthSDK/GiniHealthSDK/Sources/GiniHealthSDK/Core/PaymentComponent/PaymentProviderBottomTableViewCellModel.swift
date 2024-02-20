//
//  PaymentProviderBottomTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

final class PaymentProviderBottomTableViewCellModel {

    private var isSelected: Bool = false
    private var isPaymentProviderInstalled = false

    var shouldShowAppStoreIcon: Bool {
        !isPaymentProviderInstalled
    }
    var shouldShowSelectionIcon: Bool {
        isPaymentProviderInstalled && isSelected
    }

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark7,
                                             darkModeColor: UIColor.GiniColors.light7).uiColor()

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }

    var bankName: String
    var bankNameLabelFont: UIFont
    let bankNameLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark1,
                                                      darkModeColor: UIColor.GiniColors.light1).uiColor()

    let selectedBankBorderColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.accent1,
                                                     darkModeColor: UIColor.GiniColors.accent1).uiColor()
    let notSelectedBankBorderColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark5,
                                                        darkModeColor: UIColor.GiniColors.light5).uiColor()

    init(isSelected: Bool,
         isPaymentProviderInstalled: Bool,
         paymentProvider: PaymentProvider) {
        self.isSelected = isSelected
        self.isPaymentProviderInstalled = isPaymentProviderInstalled
        self.bankImageIconData = paymentProvider.iconData
        self.bankName = paymentProvider.name

        let defaultRegularFont: UIFont = GiniHealthConfiguration.shared.customFont.regular
        self.bankNameLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.body1] ?? defaultRegularFont
    }
}
