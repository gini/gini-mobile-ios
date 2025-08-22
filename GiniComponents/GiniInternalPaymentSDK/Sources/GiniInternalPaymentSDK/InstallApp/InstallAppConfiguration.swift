//
//  InstallAppConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct InstallAppConfiguration {
    let titleAccentColor: UIColor
    let titleFont: UIFont
    let moreInformationFont: UIFont
    let moreInformationTextColor: UIColor
    let moreInformationAccentColor: UIColor
    let moreInformationIcon: UIImage
    let appStoreIcon: UIImage
    let bankIconBorderColor: UIColor
    let closeIcon: UIImage
    let closeIconAccentColor: UIColor

    public init(titleAccentColor: UIColor,
                titleFont: UIFont,
                moreInformationFont: UIFont,
                moreInformationTextColor: UIColor,
                moreInformationAccentColor: UIColor,
                moreInformationIcon: UIImage,
                appStoreIcon: UIImage,
                bankIconBorderColor: UIColor,
                closeIcon: UIImage,
                closeIconAccentColor: UIColor) {
        self.titleAccentColor = titleAccentColor
        self.titleFont = titleFont
        self.moreInformationFont = moreInformationFont
        self.moreInformationTextColor = moreInformationTextColor
        self.moreInformationAccentColor = moreInformationAccentColor
        self.moreInformationIcon = moreInformationIcon
        self.appStoreIcon = appStoreIcon
        self.bankIconBorderColor = bankIconBorderColor
        self.closeIcon = closeIcon
        self.closeIconAccentColor = closeIconAccentColor
    }
}

public struct InstallAppStrings {
    let titlePattern: String
    let moreInformationTipPattern: String
    let moreInformationNotePattern: String
    let continueLabelText: String
    let accessibilityAppStoreText: String
    let accessibilityBankLogoText: String
    let accessibilityCloseIconText: String

    public init(titlePattern: String,
                moreInformationTipPattern: String,
                moreInformationNotePattern: String,
                continueLabelText: String,
                accessibilityAppStoreText: String,
                accessibilityBankLogoText: String,
                accessibilityCloseIconText: String) {
        self.titlePattern = titlePattern
        self.moreInformationTipPattern = moreInformationTipPattern
        self.moreInformationNotePattern = moreInformationNotePattern
        self.continueLabelText = continueLabelText
        self.accessibilityAppStoreText = accessibilityAppStoreText
        self.accessibilityBankLogoText = accessibilityBankLogoText
        self.accessibilityCloseIconText = accessibilityCloseIconText
    }
}
