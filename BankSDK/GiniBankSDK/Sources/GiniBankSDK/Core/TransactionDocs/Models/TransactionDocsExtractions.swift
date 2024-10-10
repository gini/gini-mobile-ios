//
//  TransactionDocsExtractions.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

struct TransactionDocsExtractions {
    let amountToPay: Price
    let iban: String
}

extension TransactionDocsExtractions {
    init(extractions: ExtractionResult) {
        if let amountToPayExtraction = extractions.extractions.first(where: { $0.name == "amountToPay" }) {
            amountToPay = Price(extractionString: amountToPayExtraction.value) ?? Price(value: 0, currencyCode: "EUR")
        } else {
            amountToPay = Price(value: 0, currencyCode: "EUR")
        }

        if let invoiceIBANExtraction = extractions.extractions.first(where: { $0.name == "iban"}) {
            iban = invoiceIBANExtraction.value
        } else {
            iban = ""
        }
    }
}
