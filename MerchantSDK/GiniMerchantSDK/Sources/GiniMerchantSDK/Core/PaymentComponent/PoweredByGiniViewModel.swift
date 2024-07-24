//
//  PoweredByGiniViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PoweredByGiniViewModel {
    
    // powered by Gini view
    let poweredByGiniLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.poweredByGini.label", comment: "")
    let poweredByGiniLabelFont: UIFont
    let poweredByGiniLabelAccentColor: UIColor = GiniColor.standard4.uiColor()
    let giniIcon: UIImage = GiniMerchantImage.logo.preferredUIImage()

    init() {
        self.poweredByGiniLabelFont = GiniMerchantConfiguration.shared.textStyleFonts[.caption2] ?? UIFont.systemFont(ofSize: 12, weight: .regular)
    }
}
