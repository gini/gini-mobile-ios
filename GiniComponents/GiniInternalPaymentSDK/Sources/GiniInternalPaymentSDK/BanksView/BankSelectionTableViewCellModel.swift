//
//  BankSelectionTableViewCellModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

struct BankSelectionTableViewCellModelColors {
    let backgroundColor: UIColor
    let bankNameAccentColor: UIColor
    let bankIconBorderColor: UIColor
    let selectedBankBorderColor: UIColor
    let notSelectedBankBorderColor: UIColor
}

final class BankSelectionTableViewCellModel {

    private var isSelected: Bool = false

    var shouldShowSelectionIcon: Bool {
        isSelected
    }

    let bankName: String
    let colors: BankSelectionTableViewCellModelColors
    let bankNameFont: UIFont
    let selectionIndicatorImage: UIImage
    let bankImageIcon: UIImage

    init(paymentProvider: PaymentProviderAdditionalInfo,
         bankNameFont: UIFont,
         colors: BankSelectionTableViewCellModelColors,
         selectionIndicatorImage: UIImage) {
        self.isSelected = paymentProvider.isSelected
        self.bankImageIcon = paymentProvider.paymentProvider.iconData.toImage
        self.bankName = paymentProvider.paymentProvider.name
        self.bankNameFont = bankNameFont
        self.colors = colors
        self.selectionIndicatorImage = selectionIndicatorImage
    }
}
