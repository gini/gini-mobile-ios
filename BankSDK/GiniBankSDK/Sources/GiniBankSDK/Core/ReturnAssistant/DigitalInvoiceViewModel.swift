//
//  DigitalInvoiceViewModel.swift
//  GiniBank
//
//  Created by Krzysztof Kryniecki on 18/07/2022.
//

import Foundation

public final class DigitalInvoiceViewModel {
    public var invoice: DigitalInvoice?

    init(invoice: DigitalInvoice?) {
        self.invoice = invoice
    }

    func isPayButtonEnabled() -> Bool {
        if let total = invoice?.total?.value {
            return total > 0
        }
        
        return false
    }
}
