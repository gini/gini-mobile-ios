//
//  InvoiceTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniMerchantSDK
import GiniUtilites
import UIKit

// TODO: Remove tableviewcell
final class InvoiceTableViewCellModel {
    private var invoice: InvoiceItem
    private var paymentComponentsController: PaymentComponentsController

    init(invoice: InvoiceItem,
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
    
    var ibanText: String {
        invoice.iban ?? ""
    }
    
    var isDueDataLabelHidden: Bool {
        ibanText.isEmpty
    }
    
    var isRecipientLabelHidden: Bool {
        recipientNameText.isEmpty
    }
    
    var shouldShowPaymentComponent: Bool {
        false
    }
    
    var paymentComponentView: UIView {
        return paymentComponentsController.paymentView(documentId: nil)
    }
}
