//
//  InvoiceTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniHealthSDK
import UIKit

final class InvoiceTableViewCellModel {
    private var invoice: DocumentWithExtractions
    private var bankAccentColor: String?
    private var bankTextColor: String?
    private var paymentComponentsController: PaymentComponentsController

    weak var viewDelegate: PaymentComponentViewProtocol?

    init(invoice: DocumentWithExtractions,
         paymentComponentsController: PaymentComponentsController) {
        self.invoice = invoice
        self.bankAccentColor = invoice.paymentProvider?.colors.background
        self.bankTextColor = invoice.paymentProvider?.colors.text
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
        invoice.paymentDueDate ?? ""
    }
    
    var isDueDataLabelHidden: Bool {
        dueDateText.isEmpty
    }
    
    var isRecipientLabelHidden: Bool {
        recipientNameText.isEmpty
    }
    
    var shouldShowPaymentComponent: Bool {
        invoice.isPayable
    }
    
    var paymentComponentView: UIView {
        paymentComponentsController.viewDelegate = self
        return paymentComponentsController.getPaymentView(paymentProvider: invoice.paymentProvider)
    }
}

extension InvoiceTableViewCellModel: PaymentComponentViewProtocol {
    public func didTapOnMoreInformation(documentID: String?) {
        viewDelegate?.didTapOnMoreInformation(documentID: invoice.documentID)
    }
    
    public func didTapOnBankPicker(documentID: String?) {
        viewDelegate?.didTapOnMoreInformation(documentID: invoice.documentID)
    }
    
    public func didTapOnPayInvoice(documentID: String?) {
        viewDelegate?.didTapOnBankPicker(documentID: invoice.documentID)
    }
}
