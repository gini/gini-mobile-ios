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
    private var paymentComponentsController: PaymentComponentsController

    init(invoice: DocumentWithExtractions,
         paymentComponentsController: PaymentComponentsController) {
        self.invoice = invoice
        self.paymentComponentsController = paymentComponentsController
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
        [invoice.paymentDueDate ?? "", invoice.doctorName ?? ""].joined(separator: ", ")
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
    
    var paymentComponentView: UIView {
        return paymentComponentsController.paymentView(documentId: invoice.documentId)
    }
}
