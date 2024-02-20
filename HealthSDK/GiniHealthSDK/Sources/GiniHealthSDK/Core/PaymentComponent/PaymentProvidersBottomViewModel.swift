//
//  PaymentProvidersBottomViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

final class PaymentProvidersBottomViewModel {
    
    var heightBottomSheet: CGFloat { 
        400 + heightTableView
    }
    var heightTableView: CGFloat {
        (CGFloat(paymentProviders.count) * 56.0) + (CGFloat(paymentProviders.count - 1) * 8)
    }

    var paymentProviders: PaymentProviders

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark7,
                                             darkModeColor: UIColor.GiniColors.light7).uiColor()
    let rectangleColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark5,
                                            darkModeColor: UIColor.GiniColors.light5).uiColor()

    let selectBankTitleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", comment: "")
    let selectBankLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark2,
                                                        darkModeColor: UIColor.GiniColors.light2).uiColor()
    var selectBankLabelFont: UIFont

    var closeTitleIcon: UIImage = UIImageNamedPreferred(named: "ic_close") ?? UIImage()

    let descriptionText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentproviderslist.description", comment: "")
    let descriptionLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark3,
                                                        darkModeColor: UIColor.GiniColors.light3).uiColor()
    var descriptionLabelFont: UIFont

    init(paymentProviders: PaymentProviders) {
        self.paymentProviders = paymentProviders

        let defaultRegularFont: UIFont = GiniHealthConfiguration.shared.customFont.regular
        let defaultBoldFont: UIFont = GiniHealthConfiguration.shared.customFont.regular
        let defaultMediumFont: UIFont = GiniHealthConfiguration.shared.customFont.medium

        self.selectBankLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.subtitle1] ?? defaultBoldFont
        self.descriptionLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.caption1] ?? defaultRegularFont
    }

}
