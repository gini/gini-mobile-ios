//
//  MoreInformationConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct MoreInformationConfiguration {
    let moreInformationAccentColor: UIColor
    let moreInformationTextColor: UIColor
    let moreInformationLinkFont: UIFont
    let moreInformationIcon: UIImage

    public init(moreInformationAccentColor: UIColor,
                moreInformationTextColor: UIColor,
                moreInformationLinkFont: UIFont,
                moreInformationIcon: UIImage) {
        self.moreInformationAccentColor = moreInformationAccentColor
        self.moreInformationTextColor = moreInformationTextColor
        self.moreInformationLinkFont = moreInformationLinkFont
        self.moreInformationIcon = moreInformationIcon
    }
}

public struct MoreInformationStrings {
    let moreInformationActionablePartText: String

    public init(moreInformationActionablePartText: String) {
        self.moreInformationActionablePartText = moreInformationActionablePartText
    }
}
