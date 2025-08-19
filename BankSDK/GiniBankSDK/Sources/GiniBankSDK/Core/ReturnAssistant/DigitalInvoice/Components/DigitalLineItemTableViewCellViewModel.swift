//
//  DigitalLineItemTableViewCellViewModel.swift
//  
//
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

struct DigitalLineItemTableViewCellViewModel {

    var lineItem: DigitalInvoice.LineItem

    let indexPath: IndexPath
    let invoiceNumTotal: Int
    let invoiceLineItemsCount: Int
    let nameMaxCharactersCount: Int

    var index: Int {
        indexPath.row
    }

    private var quantityString: String {
        return String.localizedStringWithFormat(Strings.quantityText, lineItem.quantity)
    }

    var nameLabelString: String? {
        guard let name = lineItem.name else { return nil }
        return "\(quantityString) \(name)"
    }

    var totalPriceString: String? {
        return lineItem.totalPrice.string
    }

    var unitPriceString: String? {
        guard let priceString = lineItem.price.string else { return nil }
        return "\(priceString) \(Strings.perUnitText)"
    }

    var modeSwitchTintColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return .giniColorScheme().toggle.trackOn.uiColor()
        case .deselected:
            return .giniColorScheme().toggle.trackOff.uiColor()
        }
    }

    var textTintColorStateDeselected: UIColor {
        .giniColorScheme().textField.disabledText.uiColor()
    }
}
extension DigitalLineItemTableViewCellViewModel {
    private struct Strings {
       static let quantityText = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.quantity",
                                                                             comment: "Quantity")
       static let perUnitText = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.unitTitle",
                                                                            comment: "per unit")
    }
}
