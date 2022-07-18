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

        if isEnabled {
            return String.localizedStringWithFormat(
                DigitalInvoiceStrings.payButtonTitle.localizedGiniBankFormat,
                numSelected,
                numTotal)
        }
        return .ginibankLocalized(resource: DigitalInvoiceStrings.noInvoicePayButtonTitle)
    }
}
