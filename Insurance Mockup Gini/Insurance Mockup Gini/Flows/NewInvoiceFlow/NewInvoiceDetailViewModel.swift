//
//  NewInvoiceDetailViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import UIKit
import GiniHealthAPILibrary
import SwiftUI


enum PaymentOptionSheetPosition: CGFloat, CaseIterable {
    case middle = 300, hidden = -100
}

protocol NewInvoiceDetailViewModelDelegate: AnyObject {
    func didTapPayAndSaveNewInvoice(withExtraction extraction: [Extraction], document: Document?)
    func saveNewInvoice(invoice: Invoice)
    func didTapPayAndSubmitNewInvoice()
    func didTapSubmitNewInvoice()
    func didTapSaveNewInvoice()
    func didTapCancel()
}

class NewInvoiceDetailViewModel: ObservableObject {
    var companyName: String
    var amount: String
    var creationDate: String
    var dueDate: String
    var iban: String
    var numberOfDaysUntilDue: Int
    var reimbursmentStatus = false
    var iconTitle = "icon_dentist"
    var sheetViewModel = ButtonSheetViewModel()
    var adress = "Musterstrasse 11, 1234 Musterstadt"
    var description = "Prophylaxe"
    var result: [Extraction]
    var document: Document?

    private var invoice: Invoice

    @Published var paymentOptionSheetPosition: PaymentOptionSheetPosition = .hidden

    weak var delegate: NewInvoiceDetailViewModelDelegate?

    init(invoice: Invoice) {
        self.invoice = invoice
        self.result = invoice.extractions
        self.document = invoice.document
        amount = invoice.priceString
        companyName = invoice.invoiceTitle
        iban = invoice.iban
        creationDate = invoice.creationDate.getFormattedDate(format: "dd MMMM, yyyy")
        dueDate = invoice.dueDate.getFormattedDate(format: "dd MMMM, yyyy")

        numberOfDaysUntilDue = Int((invoice.dueDate - Date()) / (24*60*60))
        sheetViewModel.delegate = self
    }

    func didTapCancel() {
        delegate?.didTapCancel()
    }
}

extension NewInvoiceDetailViewModel: ButtonSheetViewModelDelegate {
    func didTapPayAndSave() {
        paymentOptionSheetPosition = .hidden
        delegate?.saveNewInvoice(invoice: invoice)
        delegate?.didTapPayAndSaveNewInvoice(withExtraction: result, document: document)
    }

    func didTapPayAndSubmit() {
        paymentOptionSheetPosition = .hidden
    }

    func didTapSubmit() {
        paymentOptionSheetPosition = .hidden
    }

    func didTapSave() {
        delegate?.saveNewInvoice(invoice: invoice)
        delegate?.didTapCancel()
    }
}
