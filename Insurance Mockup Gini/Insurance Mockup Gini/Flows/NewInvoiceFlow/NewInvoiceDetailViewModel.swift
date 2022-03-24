//
//  NewInvoiceDetailViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import UIKit
import GiniBankAPILibrary
import SwiftUI


enum PaymentOptionSheetPosition: CGFloat, CaseIterable {
    case middle = 300, hidden = -100
}

enum PaySheetPosition: CGFloat, CaseIterable {
    case extended = 550, hidden = -100
}

protocol NewInvoiceDetailViewModelDelegate: AnyObject {
    func didTapPayAndSaveNewInvoice()
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
    var numberOfDaysUntilDue: Int
    var reimbursmentStatus = false
    var iconTitle = "icon_dentist"
    var sheetViewModel = ButtonSheetViewModel()

    @Published var paymentOptionSheetPosition: PaymentOptionSheetPosition = .hidden
    @Published var paySheetPosition: PaySheetPosition = .hidden

    weak var delegate: NewInvoiceDetailViewModelDelegate?

    init(results: [Extraction], document: Document?) {
        amount = results.first { $0.entity == "amount" }?.value ?? "00000"
        companyName = results.first { $0.entity == "companyname" }?.value ?? "Company name"

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
        paySheetPosition = .extended
    }

    func didTapPayAndSubmit() {
        paymentOptionSheetPosition = .hidden
    }

    func didTapSubmit() {
        paymentOptionSheetPosition = .hidden
    }

    func didTapSave() {
        paymentOptionSheetPosition = .hidden
    }
}
