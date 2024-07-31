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

    let backgroundColor: UIColor = GiniColor.standard7.uiColor()

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    var bankIconBorderColor = GiniColor.standard5.uiColor()

    var bankName: String
    var bankNameLabelFont: UIFont
    let bankNameLabelAccentColor: UIColor = GiniColor.standard1.uiColor()

    let selectedBankBorderColor: UIColor = GiniColor.accent1.uiColor()
    let notSelectedBankBorderColor: UIColor = GiniColor.standard5.uiColor()
    
    let selectionIndicatorImage: UIImage = GiniMerchantImage.selectionIndicator.preferredUIImage()

    init(paymentProvider: PaymentProviderAdditionalInfo) {
        self.isSelected = paymentProvider.isSelected
        self.bankImageIconData = paymentProvider.paymentProvider.iconData
        self.bankName = paymentProvider.paymentProvider.name
        self.bankNameLabelFont = GiniMerchantConfiguration.shared.font(for: .body1)
    }
}
