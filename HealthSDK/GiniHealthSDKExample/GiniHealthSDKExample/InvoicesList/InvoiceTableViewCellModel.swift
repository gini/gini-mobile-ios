//
//  InvoiceTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniHealthSDK
import GiniCaptureSDK
import UIKit

final class InvoiceTableViewCellModel {
    
    var invoice: DocumentWithExtractions
    var giniConfiguration: GiniHealthConfiguration
    
    init(invoice: DocumentWithExtractions, giniConfiguration: GiniHealthConfiguration) {
        self.invoice = invoice
        self.giniConfiguration = giniConfiguration
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
        invoice.paymentDueDate ?? ""
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
        let paymentComponentController = GiniHealthSDK.PaymentComponentController(giniConfiguration: giniConfiguration)
        paymentComponentController.delegate = self
        return paymentComponentController.getPaymentView(bankName: invoice.bankName,
                            bankIconName: invoice.bankIconName)
    }
}

extension InvoiceTableViewCellModel: PaymentComponentControllerProtocol {
    public func didTapOnMoreInformations() {
        // MARK: TODO in next tasks
        Log("Tapped on More Information on :\(invoice.documentID)", event: .success)
    }
    
    public func didTapOnBankPicker() {
        // MARK: TODO in next tasks
        Log("Tapped on Bank Picker on :\(invoice.documentID)", event: .success)
    }
    
    public func didTapOnPayInvoice() {
        // MARK: TODO in next tasks
        Log("Tapped on Pay Invoice on :\(invoice.documentID)", event: .success)
    }
}
