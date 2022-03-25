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

    init(iconName: String, title: String, paid: Bool, reimbursed: ReimbursmentState, price: String) {
        self.iconName = iconName
        self.title = title
        self.paid = paid
        self.reimbursed = reimbursed
        self.price = price
    }
}

enum ReimbursmentState: String {
    case notSent = "Not sent"
    case sent = "Sent"
    case reimbursed = "Reimbursed"
}
