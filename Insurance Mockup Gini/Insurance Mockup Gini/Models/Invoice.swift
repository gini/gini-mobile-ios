//
//  Invoice.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 28.03.2022.
//

import Foundation
import GiniHealthAPILibrary

struct Invoice {
    var invoiceID: String
    var invoiceTitle: String
    var priceString: String
    var creationDate: Date
    var dueDate: Date
    var iban: String
    var reimbursmentStatus: ReimbursmentState
    var paid: Bool
    var iconTitle: String
    var adress: String
    var description: String
    var extractions: [Extraction]
    var document: Document?

    init(id: String = UUID().uuidString,
         extractions: [Extraction],
         document: Document?,
         iconTitle: String = "icon_dentist",
         adress: String = "Munich",
         desciption: String = "Lorem ipsum") {
        invoiceID = id
        invoiceTitle = extractions.first { $0.entity == "companyname" }?.value ?? "Company name"
        priceString = extractions.first { $0.entity == "amount" }?.value ?? "00000"
        creationDate = document?.creationDate ?? Date()
        // Adding 7 days to the creation date in order to have mocked due date
        dueDate = document?.creationDate.addingTimeInterval(7*24*60*60) ?? Date().addingTimeInterval(7*24*60*60)
        iban = extractions.first { $0.entity == "iban" }?.value ?? "123456789"
        reimbursmentStatus = .notSent
        paid = false
        self.iconTitle = iconTitle
        self.adress = adress
        self.description = desciption
        self.extractions = extractions
        self.document = document
    }
}
