//
//  InvoiceListDataModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import Foundation

final class InvoiceListDataModel {
    var invoiceList = [
        InvoiceItemCellViewModel(iconName: "icon_dentist", title: "Dr. Theresa Müller", paid: false, reimbursed: .notSent, price: "450.11 EUR"),
        InvoiceItemCellViewModel(iconName: "icon_book", title: "Dr. Mara Klinsmann", paid: true, reimbursed: .sent, price: "145.99 EUR"),
        InvoiceItemCellViewModel(iconName: "icon_book", title: "Dr. Mara Klinsmann", paid: true, reimbursed: .reimbursed, price: "445.99 EUR")
    ]

    var oldInvoiceList = [
        InvoiceItemCellViewModel(iconName: "icon_dentist", title: "Universitätsklinikum Berlin", paid: false, reimbursed: .notSent, price: "45.12 EUR"),
        InvoiceItemCellViewModel(iconName: "icon_book", title: "Bayer Klinikum", paid: true, reimbursed: .sent, price: "15.89 EUR"),
        InvoiceItemCellViewModel(iconName: "icon_dentist", title: "Universitätsklinikum Frankfurt", paid: true, reimbursed: .reimbursed, price: "145.99 EUR"),
    ]

    func addNewInvoice(invoice: InvoiceItemCellViewModel) {
        invoiceList.insert(invoice, at: 0)
    }
}
