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
    var price: Double
    var currency: String = "EUR"
    var creationDate: Date
    var dueDate = Date().addingTimeInterval(Double.random(in: 5..<24)*24*60*60)
    var iban: String
    var reimbursmentStatus: ReimbursmentState
    var paid: Bool
    var iconTitle: String
    var adress: String
    var description: String
    var paymentRequestID: String?
    var extractions: [Extraction]
    var document: Document?

    init(id: String = UUID().uuidString,
         extractions: [Extraction],
         document: Document?,
         iconTitle: String = "icon_dentist",
         adress: String = "Munich",
         desciption: String = "Lorem ipsum") {
        invoiceID = id

        // adress from extraction
        invoiceTitle = extractions.first { $0.entity == "text" }?.value ?? "Company name"
        let priceStrings = extractions.first { $0.entity == "amount" }?.value.split(separator: ":") ?? ["12", "EUR"]
        price = Double(priceStrings[0]) ?? 123.9
        currency = String(priceStrings[1])
        creationDate = document?.creationDate ?? Date()
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
