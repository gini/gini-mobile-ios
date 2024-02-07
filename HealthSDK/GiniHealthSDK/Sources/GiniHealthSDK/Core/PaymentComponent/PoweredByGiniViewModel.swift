//
//  PoweredByGiniViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PoweredByGiniViewModel {
    
    // powered by Gini view
    let poweredByGiniLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.poweredByGini.label", comment: "")
    let poweredByGiniLabelFont: UIFont
    let poweredByGiniLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark4, 
                                                           darkModeColor: UIColor.GiniColors.light4).uiColor()
    let giniIconName: String = "giniLogo"

    init() {
        self.poweredByGiniLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.caption2] ?? GiniHealthConfiguration.shared.customFont.regular
    }
}
