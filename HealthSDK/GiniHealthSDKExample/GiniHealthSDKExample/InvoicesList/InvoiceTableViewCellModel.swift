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
    private var bankAccentColor: GiniHealthSDK.GiniColor
    private var bankTextColor: GiniHealthSDK.GiniColor
    private var paymentComponentsController: PaymentComponentsController

    init(invoice: DocumentWithExtractions,
         paymentComponentsController: PaymentComponentsController) {
        self.invoice = invoice
        self.bankAccentColor = invoice.bank.accentColor.giniColor
        self.bankTextColor = invoice.bank.textColor.giniColor
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
        invoice.isPayable ?? false
    }
    
    var paymentComponentView: UIView {
        return paymentComponentsController.getPaymentView(bankName: invoice.bank.name,
                                                          bankIconName: invoice.bank.iconName,
                                                          payInvoiceAccentColor: bankAccentColor,
                                                          payInvoiceTextColor: bankTextColor)
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

    public func isLoadingStateChanged(isLoading: Bool) {
        // MARK: TODO in next tasks
        Log("Is loading state: \(isLoading)", event: .success)
    }
}
