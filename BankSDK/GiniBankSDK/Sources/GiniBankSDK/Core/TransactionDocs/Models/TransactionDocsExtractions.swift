//
//  TransactionDocsExtractions.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

public struct TransactionDocsExtractions {
    let amountToPay: Price
    let iban: String
}

public extension TransactionDocsExtractions {
    init(extractions: [Extraction]) {
        if let amountToPayExtraction = extractions.first(where: { $0.name == "amountToPay" }) {
            amountToPay = Price(extractionString: amountToPayExtraction.value) ?? Price(value: 0, currencyCode: "EUR")
        } else {
            amountToPay = Price(value: 0, currencyCode: "EUR")
        }

        if let invoiceIBANExtraction = extractions.first(where: { $0.name == "iban"}) {
            iban = invoiceIBANExtraction.value
        } else {
            iban = ""
        }
    }
}
