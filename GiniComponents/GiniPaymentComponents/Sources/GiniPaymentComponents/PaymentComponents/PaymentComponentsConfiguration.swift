//
//  PaymentComponentsConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct PaymentComponentsConfiguration {
    let selectYourBankLabelFont: UIFont
    let selectYourBankAccentColor: UIColor
    let chevronDownIcon: UIImage
    let chevronDownIconColor: UIColor
    let notInstalledBankTextColor: UIColor

    public init(selectYourBankLabelFont: UIFont,
                selectYourBankAccentColor: UIColor,
                chevronDownIcon: UIImage,
                chevronDownIconColor: UIColor,
                notInstalledBankTextColor: UIColor) {
        self.selectYourBankLabelFont = selectYourBankLabelFont
        self.selectYourBankAccentColor = selectYourBankAccentColor
        self.chevronDownIcon = chevronDownIcon
        self.chevronDownIconColor = chevronDownIconColor
        self.notInstalledBankTextColor = notInstalledBankTextColor
    }
}

public struct PaymentComponentsStrings {
    let selectYourBankLabelText: String
    let placeholderBankNameText: String
    let ctaLabelText: String

    public init(selectYourBankLabelText: String,
                placeholderBankNameText: String,
                ctaLabelText: String) {
        self.selectYourBankLabelText = selectYourBankLabelText
        self.placeholderBankNameText = placeholderBankNameText
        self.ctaLabelText = ctaLabelText
    }
}
