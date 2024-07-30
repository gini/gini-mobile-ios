//
//  PoweredByGiniConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct PoweredByGiniConfiguration {
    let poweredByGiniLabelFont: UIFont
    let poweredByGiniLabelAccentColor: UIColor
    let giniIcon: UIImage

    public init(poweredByGiniLabelFont: UIFont,
                poweredByGiniLabelAccentColor: UIColor,
                giniIcon: UIImage) {
        self.poweredByGiniLabelFont = poweredByGiniLabelFont
        self.poweredByGiniLabelAccentColor = poweredByGiniLabelAccentColor
        self.giniIcon = giniIcon
    }
}

public struct PoweredByGiniStrings {
    let poweredByGiniText: String

    public init(poweredByGiniText: String) {
        self.poweredByGiniText = poweredByGiniText
    }
}
