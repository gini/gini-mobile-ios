//
//  ShareInvoiceSingleAppConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct ShareInvoiceConfiguration {
    public let titleFont: UIFont
    public let titleAccentColor: UIColor
    public let descriptionFont: UIFont
    public let descriptionTextColor: UIColor
    public let descriptionAccentColor: UIColor
    public let tipIcon: UIImage
    public let tipFont: UIFont
    public let tipLinkFont: UIFont
    public let tipAccentColor: UIColor
    public let tipTextColor: UIColor
    public let moreIcon: UIImage
    public let bankIconBorderColor: UIColor
    public let appsBackgroundColor: UIColor

    public let singleAppTitleFont: UIFont
    public let singleAppTitleColor: UIColor
    public let singleAppIconBorderColor: UIColor
    public let singleAppIconBackgroundColor: UIColor

    public init(titleFont: UIFont,
                titleAccentColor: UIColor,
                descriptionFont: UIFont,
                descriptionTextColor: UIColor,
                descriptionAccentColor: UIColor,
                tipIcon: UIImage,
                tipFont: UIFont,
                tipLinkFont: UIFont,
                tipAccentColor: UIColor,
                tipTextColor: UIColor,
                moreIcon: UIImage,
                bankIconBorderColor: UIColor,
                appsBackgroundColor: UIColor,
                singleAppTitleFont: UIFont,
                singleAppTitleColor: UIColor,
                singleAppIconBorderColor: UIColor,
                singleAppIconBackgroundColor: UIColor) {
        self.titleFont = titleFont
        self.titleAccentColor = titleAccentColor
        self.descriptionFont = descriptionFont
        self.descriptionTextColor = descriptionTextColor
        self.descriptionAccentColor = descriptionAccentColor
        self.tipIcon = tipIcon
        self.tipFont = tipFont
        self.tipLinkFont = tipLinkFont
        self.tipAccentColor = tipAccentColor
        self.tipTextColor = tipTextColor
        self.moreIcon = moreIcon
        self.bankIconBorderColor = bankIconBorderColor
        self.appsBackgroundColor = appsBackgroundColor
        self.singleAppTitleFont = singleAppTitleFont
        self.singleAppTitleColor = singleAppTitleColor
        self.singleAppIconBorderColor = singleAppIconBorderColor
        self.singleAppIconBackgroundColor = singleAppIconBackgroundColor
    }
}

public struct ShareInvoiceStrings {
    let tipActionablePartText: String
    let continueLabelText: String
    let singleAppTitle: String
    let singleAppMore: String
    let titleTextPattern: String
    let descriptionTextPattern: String
    let tipLabelPattern: String

    public init(tipActionablePartText: String,
                continueLabelText: String,
                singleAppTitle: String,
                singleAppMore: String,
                titleTextPattern: String,
                descriptionTextPattern: String,
                tipLabelPattern: String) {
        self.tipActionablePartText = tipActionablePartText
        self.continueLabelText = continueLabelText
        self.singleAppTitle = singleAppTitle
        self.singleAppMore = singleAppMore
        self.titleTextPattern = titleTextPattern
        self.descriptionTextPattern = descriptionTextPattern
        self.tipLabelPattern = tipLabelPattern
    }
}


