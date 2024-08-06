//
//  InvoiceTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniMerchantSDK
import GiniUtilites
import UIKit

final class InvoiceTableViewCellModel {
    private var invoice: InvoiceItem

    init(invoice: InvoiceItem) {
        self.invoice = invoice
    }
    
    var recipientNameText: String {
        invoice.recipient ?? ""
    }
    
    var amountToPayText: String {
        if let amoountToPay = invoice.amountToPay, let amountToPayFormatted = Price(extractionString: amoountToPay) {
            return amountToPayFormatted.string ?? ""
        }
        return ""
    }

    var ibanText: String {
        invoice.iban ?? ""
    }

    var isRecipientLabelHidden: Bool {
        recipientNameText.isEmpty
    }
}
