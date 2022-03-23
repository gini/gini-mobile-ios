//
//  NewInvoiceDetailViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import Foundation
import GiniBankAPILibrary

protocol NewInvoiceDetailViewModelDelegate: AnyObject {
    func didTapCancel()
}

class NewInvoiceDetailViewModel {
    var companyName: String
    var amount: String
    var creationDate: String
    var dueDate: String
    var numberOfDaysUntilDue: Int

    weak var delegate: NewInvoiceDetailViewModelDelegate?

    init(results: [Extraction], document: Document?) {
        amount = results.first { $0.entity == "amount" }?.value ?? "00000"
        companyName = results.first { $0.entity == "companyname" }?.value ?? "Company name"

        creationDate = (document?.creationDate ?? Date()).getFormattedDate(format: "dd MMMM, yyyy")

        // Adding 7 days to the creation date in order to have mocked due date
        let dateOffset = document?.creationDate.addingTimeInterval(7*24*60*60) ?? Date().addingTimeInterval(7*24*60*60)
        dueDate = dateOffset.getFormattedDate(format: "dd MMMM, yyyy")

        numberOfDaysUntilDue = Int((dateOffset - Date()) / (24*60*60))
    }

    func didTapCancel() {
        delegate?.didTapCancel()
    }
}
