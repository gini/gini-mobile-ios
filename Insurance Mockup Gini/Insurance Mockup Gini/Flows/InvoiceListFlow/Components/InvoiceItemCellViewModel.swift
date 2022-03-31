//
//  InvoiceItemCellViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import Foundation

class InvoiceItemCellViewModel {
    var id: String
    var iconName: String
    var title: String
    var paid: Bool
    var reimbursed: ReimbursmentState
    var price: String
    var creationDate: Date
    var numberOfDaysUntilDue: Int

    init(invoice: Invoice) {
        self.iconName = invoice.iconTitle
        self.id = invoice.invoiceID
        self.title = invoice.invoiceTitle
        self.paid = invoice.paid
        self.reimbursed = invoice.reimbursmentStatus
        self.price = "\(String(format: "%.2f", invoice.price)) \(invoice.currency)"
        self.creationDate = invoice.creationDate
        self.numberOfDaysUntilDue = Int((invoice.dueDate - Date()) / (24*60*60))
    }
}

enum ReimbursmentState: String {
    case notSent = "Not sent"
    case sent = "Submitted"
    case reimbursed = "Reimbursed"
}
