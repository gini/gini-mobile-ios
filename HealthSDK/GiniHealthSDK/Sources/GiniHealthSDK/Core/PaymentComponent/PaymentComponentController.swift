//
//  PaymentComponentController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

public protocol PaymentComponentControllerProtocol: AnyObject, PaymentComponentViewModelProtocol {
    func didTapOnMoreInformations()
    func didTapOnBankPicker()
    func didTapOnPayInvoice()
}

public final class PaymentComponentController: NSObject, PaymentComponentControllerProtocol {
    
    public weak var delegate: PaymentComponentControllerProtocol?
    
    var giniConfiguration: GiniHealthConfiguration
    
    public init(giniConfiguration: GiniHealthConfiguration) {
        self.giniConfiguration = giniConfiguration
    }
    
    public func getPaymentView(bankName: String, 
                               bankIconName: String,
                               payInvoiceAccentColor: GiniColor,
                               payInvoiceTextColor: GiniColor) -> UIView {
        let paymentComponentView = PaymentComponentView()
        let paymentComponentViewModel = PaymentComponentViewModel(giniConfiguration: giniConfiguration, 
                                                                  bankName: bankName,
                                                                  bankIconName: bankIconName,
                                                                  payInvoiceAccentColor: payInvoiceAccentColor,
                                                                  payInvoiceTextColor: payInvoiceTextColor)
        paymentComponentViewModel.delegate = delegate
        paymentComponentView.viewModel = paymentComponentViewModel
        return paymentComponentView
    }
}

extension PaymentComponentController: PaymentComponentViewModelProtocol {
    public func didTapOnMoreInformations() {
        delegate?.didTapOnMoreInformations()
    }
    
    public func didTapOnBankPicker() {
        delegate?.didTapOnBankPicker()
    }
    
    public func didTapOnPayInvoice() {
        delegate?.didTapOnPayInvoice()
    }
}
