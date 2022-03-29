//
//  InvoiceListDataModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import Foundation
import GiniBankAPILibrary

final class InvoiceListDataModel {
    private static var dayTimeInterval: Double = 60*60*24
    var updateList: (() -> Void)?
    var invoiceData: [Invoice] = [
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Dr. Theresa Müller"
            invoice.priceString = "450.11 EUR"
            invoice.creationDate = Date().addingTimeInterval(-1 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Dr. Mara Klinsmann"
            invoice.iconTitle = "icon_book"
            invoice.priceString = "145.99 EUR"
            invoice.creationDate = Date().addingTimeInterval(-4 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Dr. Mara Klinsmann"
            invoice.iconTitle = "icon_book"
            invoice.priceString = "145.99 EUR"
            invoice.paid = true
            invoice.reimbursmentStatus = .sent
            invoice.creationDate = Date().addingTimeInterval(-7 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Universitätsklinikum Berlin"
            invoice.iconTitle = "icon_book"
            invoice.priceString = "45.12 EUR"
            invoice.creationDate = Date().addingTimeInterval(-40 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Bayer Klinikum"
            invoice.iconTitle = "icon_dentist"
            invoice.priceString = "15.89 EUR"
            invoice.paid = true
            invoice.reimbursmentStatus = .sent
            invoice.creationDate = Date().addingTimeInterval(-45 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Universitätsklinikum Frankfurt"
            invoice.iconTitle = "icon_book"
            invoice.priceString = "15.89 EUR"
            invoice.paid = true
            invoice.reimbursmentStatus = .reimbursed
            invoice.creationDate = Date().addingTimeInterval(-45 * dayTimeInterval)
            return invoice
        }()
    ]

    lazy var invoiceList = invoiceData.map { InvoiceItemCellViewModel(invoice: $0) }

    func addNewInvoice(invoice: Invoice) {
        invoiceData.insert(invoice, at: 0)
        updateList?()
    }
}
