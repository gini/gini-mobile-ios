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
    let poweredByGiniLabelAccentColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark4).uiColor()
    let giniIconName: String = "giniLogo"
    
    init(giniConfiguration: GiniHealthConfiguration) {
        self.poweredByGiniLabelFont = giniConfiguration.customFont.with(weight: .regular, size: 12, style: .caption2)
    }
}
