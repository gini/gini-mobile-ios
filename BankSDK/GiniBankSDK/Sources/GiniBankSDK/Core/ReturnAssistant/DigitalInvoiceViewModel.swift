//
//  DigitalInvoiceViewModel.swift
//  GiniBank
//
//  Created by Krzysztof Kryniecki on 18/07/2022.
//

import Foundation

final class DigitalInvoiceViewModel {
    func isPayButtonEnabled(total: Decimal) -> Bool {
        return total > 0
    }
    
    func payButtonTitle(
        isEnabled: Bool = false,
        numSelected: Int,
        numTotal: Int
    ) -> String {

        if isEnabled && numSelected != 0 {
            return String.localizedStringWithFormat(
                DigitalInvoiceStrings.payButtonTitle.localizedGiniBankFormat,
                numSelected,
                numTotal)
        }
        if numSelected == 0 {
            return .ginibankLocalized(resource: DigitalInvoiceStrings.payButtonOtherCharges)
        }
        return .ginibankLocalized(resource: DigitalInvoiceStrings.disabledPayButtonTitle)
    }
}
