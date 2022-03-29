//
//  InvoiceItemCellViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import Foundation

class InvoiceItemCellViewModel {
    var id: String = UUID().uuidString
    var iconName: String
    var title: String
    var paid: Bool
    var reimbursed: ReimbursmentState
    var price: String
    var creationDate: Date

    init(invoice: Invoice) {
        self.iconName = invoice.iconTitle
        self.id = invoice.invoiceID
        self.title = invoice.invoiceTitle
        self.paid = invoice.paid
        self.reimbursed = invoice.reimbursmentStatus
        self.price = invoice.priceString
        self.creationDate = invoice.creationDate
    }
}

enum ReimbursmentState: String {
    case notSent = "Not sent"
    case sent = "Sent"
    case reimbursed = "Reimbursed"
}
