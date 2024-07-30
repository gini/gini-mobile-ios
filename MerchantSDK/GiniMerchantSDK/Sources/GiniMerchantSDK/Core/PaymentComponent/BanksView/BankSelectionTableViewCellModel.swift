//
//  BankSelectionTableViewCellModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

final class BankSelectionTableViewCellModel {

    private var isSelected: Bool = false

    var shouldShowSelectionIcon: Bool {
        isSelected
    }

    let bankName: String
    let backgroundColor: UIColor
    let bankIconBorderColor: UIColor
    let bankNameFont: UIFont
    let bankNameAccentColor: UIColor
    let selectedBankBorderColor: UIColor
    let notSelectedBankBorderColor: UIColor
    let selectionIndicatorImage: UIImage

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }

    init(paymentProvider: PaymentProviderAdditionalInfo, 
         backgroundColor: UIColor,
         bankNameFont: UIFont,
         bankNameAccentColor: UIColor,
         bankIconBorderColor: UIColor,
         selectedBankBorderColor: UIColor,
         notSelectedBankBorderColor: UIColor,
         selectionIndicatorImage: UIImage) {
        self.isSelected = paymentProvider.isSelected
        self.bankImageIconData = paymentProvider.paymentProvider.iconData
        self.bankName = paymentProvider.paymentProvider.name
        self.bankNameFont = bankNameFont
        self.backgroundColor = backgroundColor
        self.bankNameAccentColor = bankNameAccentColor
        self.bankIconBorderColor = bankIconBorderColor
        self.selectedBankBorderColor = selectedBankBorderColor
        self.notSelectedBankBorderColor = notSelectedBankBorderColor
        self.selectionIndicatorImage = selectionIndicatorImage
    }
}