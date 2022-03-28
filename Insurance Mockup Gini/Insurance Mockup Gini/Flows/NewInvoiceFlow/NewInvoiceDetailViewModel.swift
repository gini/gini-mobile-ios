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

enum PaySheetPosition: CGFloat, CaseIterable {
    case extended = 550, hidden = -100
}

protocol NewInvoiceDetailViewModelDelegate: AnyObject {
    func didTapPayAndSaveNewInvoice(withExtraction extraction: [Extraction], document: Document?)
    func didTapPayAndSubmitNewInvoice()
    func didTapSubmitNewInvoice()
    func didTapSaveNewInvoice()
    func didTapCancel()
}

class NewInvoiceDetailViewModel: ObservableObject {
    @Published var companyName: String
    @Published var amount: String
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

    @Published var paymentOptionSheetPosition: PaymentOptionSheetPosition = .hidden
    @Published var paySheetPosition: PaySheetPosition = .hidden

    weak var delegate: NewInvoiceDetailViewModelDelegate?

    init(results: [Extraction], document: Document?) {
        self.result = results
        self.document = document
        amount = results.first { $0.entity == "amount" }?.value ?? "00000"
        companyName = results.first { $0.entity == "companyname" }?.value ?? "Company name"
        iban = results.first { $0.entity == "iban" }?.value ?? "123456789"
        creationDate = (document?.creationDate ?? Date()).getFormattedDate(format: "dd MMMM, yyyy")

        // Adding 7 days to the creation date in order to have mocked due date
        let dateOffset = document?.creationDate.addingTimeInterval(7*24*60*60) ?? Date().addingTimeInterval(7*24*60*60)
        dueDate = dateOffset.getFormattedDate(format: "dd MMMM, yyyy")

        numberOfDaysUntilDue = Int((dateOffset - Date()) / (24*60*60))
        sheetViewModel.delegate = self
    }

    func didTapCancel() {
        delegate?.didTapCancel()
    }
}

extension NewInvoiceDetailViewModel: ButtonSheetViewModelDelegate {
    func didTapPayAndSave() {
        paymentOptionSheetPosition = .hidden
        delegate?.didTapPayAndSaveNewInvoice(withExtraction: result, document: document)
    }

    func didTapPayAndSubmit() {
        paymentOptionSheetPosition = .hidden
    }

    func didTapSubmit() {
        paymentOptionSheetPosition = .hidden
    }

    func didTapSave() {
        delegate?.didTapSaveNewInvoice()
        paymentOptionSheetPosition = .hidden
    }
}
