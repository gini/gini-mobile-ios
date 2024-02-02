//
//  InvoiceTableViewCellModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniHealthSDK
import UIKit

protocol InvoiceTableViewCellProtocol: AnyObject {
    func isLoadingStateChanged(isLoading: Bool)
}

final class InvoiceTableViewCellModel {
    private var invoice: DocumentWithExtractions
    private var bankAccentColor: String?
    private var bankTextColor: String?
    private var paymentComponentsController: PaymentComponentsController

    weak var delegate: InvoiceTableViewCellProtocol?

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
        invoice.isPayable ?? false
    }
    
    var paymentComponentView: UIView {
        paymentComponentsController.delegate = self
        return paymentComponentsController.getPaymentView(paymentProvider: invoice.paymentProvider)
    }
}

extension InvoiceTableViewCellModel: PaymentComponentsControllerProtocol {
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
        delegate?.isLoadingStateChanged(isLoading: isLoading)
    }
}
