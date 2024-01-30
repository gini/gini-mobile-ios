//
//  PaymentComponentController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

public protocol PaymentComponentControllerProtocol: AnyObject, PaymentComponentViewModelProtocol {
    func didTapOnMoreInformations()
    func didTapOnBankPicker()
    func didTapOnPayInvoice()
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine, iOS 11 supported
}

public final class PaymentComponentsController: NSObject, PaymentComponentControllerProtocol {
    
    public weak var delegate: PaymentComponentControllerProtocol?
    
    private var giniConfiguration: GiniHealthConfiguration
    private var giniHealth: GiniHealth
    var paymentProviders: PaymentProviders = []

    public init(giniConfiguration: GiniHealthConfiguration, giniHealth: GiniHealth) {
        self.giniConfiguration = giniConfiguration
        self.giniHealth = giniHealth
    }

    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }

    var paymentComponentView: PaymentComponentView!

    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        giniHealth.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    public func getPaymentView(bankName: String, 
                               bankIconName: String,
                               payInvoiceAccentColor: GiniColor,
                               payInvoiceTextColor: GiniColor) -> UIView {
        paymentComponentView = PaymentComponentView()
        let paymentComponentViewModel = PaymentComponentViewModel(giniConfiguration: giniConfiguration, 
                                                                  bankName: bankName,
                                                                  bankIconName: bankIconName,
                                                                  payInvoiceAccentColor: payInvoiceAccentColor,
                                                                  payInvoiceTextColor: payInvoiceTextColor,
                                                                  giniHealth: giniHealth)
        paymentComponentViewModel.delegate = delegate
        paymentComponentView.viewModel = paymentComponentViewModel
        return paymentComponentView
    }
}

extension PaymentComponentsController: PaymentComponentViewModelProtocol {
    public func didTapOnMoreInformations() {
        delegate?.didTapOnMoreInformations()
    }
    
    public func didTapOnBankPicker() {
        delegate?.didTapOnBankPicker()
    }
    
    public func didTapOnPayInvoice() {
        delegate?.didTapOnPayInvoice()
    }

    public func isLoadingStateChanged(isLoading: Bool) {
        delegate?.isLoadingStateChanged(isLoading: isLoading)
    }
}
