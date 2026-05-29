//
//  BanksBottomConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct BankSelectionConfiguration {
    let descriptionAccentColor: UIColor
    let descriptionFont: UIFont
    let selectBankAccentColor: UIColor
    let selectBankFont: UIFont

    let bankCellBackgroundColor: UIColor
    let bankCellIconBorderColor: UIColor
    let bankCellNameFont: UIFont
    let bankCellNameAccentColor: UIColor
    let bankCellSelectedBorderColor: UIColor
    let bankCellNotSelectedBorderColor: UIColor
    let bankCellSelectionIndicatorImage: UIImage

    public init(descriptionAccentColor: UIColor,
                descriptionFont: UIFont,
                selectBankAccentColor: UIColor,
                selectBankFont: UIFont,
                bankCellBackgroundColor: UIColor,
                bankCellIconBorderColor: UIColor,
                bankCellNameFont: UIFont,
                bankCellNameAccentColor: UIColor,
                bankCellSelectedBorderColor: UIColor,
                bankCellNotSelectedBorderColor: UIColor,
                bankCellSelectionIndicatorImage: UIImage) {
        self.descriptionAccentColor = descriptionAccentColor
        self.descriptionFont = descriptionFont
        self.selectBankAccentColor = selectBankAccentColor
        self.selectBankFont = selectBankFont
        self.bankCellBackgroundColor = bankCellBackgroundColor
        self.bankCellIconBorderColor = bankCellIconBorderColor
        self.bankCellNameFont = bankCellNameFont
        self.bankCellNameAccentColor = bankCellNameAccentColor
        self.bankCellSelectedBorderColor = bankCellSelectedBorderColor
        self.bankCellNotSelectedBorderColor = bankCellNotSelectedBorderColor
        self.bankCellSelectionIndicatorImage = bankCellSelectionIndicatorImage
    }
}

public struct BanksBottomStrings {
    let selectBankTitleText: String
    let descriptionText: String

    public init(selectBankTitleText: String,
                descriptionText: String) {
        self.selectBankTitleText = selectBankTitleText
        self.descriptionText = descriptionText
    }
}
