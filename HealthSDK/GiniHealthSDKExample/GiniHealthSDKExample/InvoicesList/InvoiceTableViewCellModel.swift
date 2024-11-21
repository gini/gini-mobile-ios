//
//  InvoiceTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthSDK
import GiniUtilites
import UIKit

final class InvoiceTableViewCellModel {
    private var invoice: DocumentWithExtractions
    private var health: GiniHealth

    init(invoice: DocumentWithExtractions,
         health: GiniHealth) {
        self.invoice = invoice
        self.health = health
    }
    
    var recipientNameText: String {
        invoice.recipient ?? ""
    }
    
    var amountToPayText: String {
        if let amoountToPay = invoice.amountToPay, let amountToPayFormatted = Price(extractionString: amoountToPay) {
            return amountToPayFormatted.string ?? ""
        }
        return ""
    }
    
    var dueDateText: String {
        var textToReturn: [String] = []
        if let paymentDueDate = invoice.paymentDueDate {
            textToReturn.append(paymentDueDate)
        }
        if let doctorName = invoice.doctorName {
            textToReturn.append(doctorName)
        }
        return textToReturn.joined(separator: ", ")
    }
    
    var isDueDataLabelHidden: Bool {
        dueDateText.isEmpty
    }
    
    var isRecipientLabelHidden: Bool {
        recipientNameText.isEmpty
    }
    
    var shouldShowPaymentComponent: Bool {
        invoice.isPayable ?? false
    }

    var bankLogosToShow: [Data]? {
        health.fetchBankLogos().logos
    }

    var additionalBankNumberToShow: Int? {
        health.fetchBankLogos().additionalBankCount
    }
}
