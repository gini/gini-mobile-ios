//
//  PoweredByGiniViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PoweredByGiniViewModel {
    
    // powered by Gini view
    let poweredByGiniLabelText: String = GiniLocalized.string("ginihealth.paymentcomponent.poweredByGini.label", comment: "")
    let poweredByGiniLabelFont: UIFont
    let poweredByGiniLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4, 
                                                           darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
    let giniIconName: String = "giniLogo"

    init() {
        self.poweredByGiniLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.caption2] ?? UIFont.systemFont(ofSize: 12, weight: .regular)
    }
}
