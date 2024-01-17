//
//  InvoiceTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniHealthSDK

final class InvoiceTableViewCellModel {
    
    var invoice: DocumentWithExtractions
    
    init(invoice: DocumentWithExtractions) {
        self.invoice = invoice
    }
    
    var recipientNameText: String {
        invoice.extractionResult.payment?.first?.first(where: {$0.name == "payment_recipient"})?.value ?? ""
    }
    
    var amountToPayText: String {
        if let amountString = invoice.extractionResult.payment?.first?.first(where: {$0.name == "amount_to_pay"})?.value, let amountToPay = Price(extractionString: amountString) {
            return amountToPay.string ?? ""
        }
        return ""
    }
    
    var dueDateText: String {
        if let dueDate = invoice.extractionResult.extractions.first(where: {$0.name == "payment_due_date"})?.value {
            return dueDate
        }
        return ""
    }
    
    var isDueDataLabelHidden: Bool {
        return dueDateText.isEmpty
    }
}
