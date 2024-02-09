//
//  PaymentComponentController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

public protocol GiniDocument {
    var documentID: String { get set }
    var amountToPay: String? { get set }
    var paymentDueDate: String? { get set }
    var recipient: String? { get set }
    var isPayable: Bool { get set }
    var paymentProvider: PaymentProvider? { get set }
}

public protocol PaymentComponentsControllerProtocol: AnyObject {
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine, iOS 11 supported
    func didFetchedPaymentProviders(_ paymentProviders: PaymentProviders)
    func didReceivedErrorOnPaymentProviders(_ error: GiniHealthError)
}

public final class PaymentComponentsController: NSObject {
    public weak var delegate: PaymentComponentsControllerProtocol?
    public weak var viewDelegate: PaymentComponentViewProtocol?

    private var giniHealth: GiniHealth
    private var paymentProviders: PaymentProviders = []

    public init(giniHealth: GiniHealth) {
        self.giniHealth = giniHealth
        super.init()
        DispatchQueue.main.async {
            self.isLoading = true
            self.giniHealth.checkIfAnyPaymentProviderAvailable { [weak self] result in
                self?.isLoading = false
                switch result {
                case let .success(paymentProviders):
                    self?.paymentProviders = paymentProviders
                    self?.delegate?.didFetchedPaymentProviders(paymentProviders)
                case let .failure(error):
                    self?.delegate?.didReceivedErrorOnPaymentProviders(error)
                }
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }

    var paymentComponentView: PaymentComponentView!

    public func obtainFirstPaymentProvider() -> PaymentProvider? {
        paymentProviders.first
    }

    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        giniHealth.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    public func getPaymentView(paymentProvider: PaymentProvider?) -> UIView {
        paymentComponentView = PaymentComponentView()
        let paymentComponentViewModel = PaymentComponentViewModel(paymentProvider: paymentProvider,
                                                                  giniHealth: giniHealth)
        paymentComponentViewModel.delegate = viewDelegate
        paymentComponentView.viewModel = paymentComponentViewModel
        return paymentComponentView
    }
}

extension PaymentComponentsController: PaymentComponentViewProtocol {
    public func didTapOnMoreInformation(documentID: String?) {
        viewDelegate?.didTapOnMoreInformation()
    }
    
    public func didTapOnBankPicker(documentID: String?) {
        viewDelegate?.didTapOnBankPicker()
    }
    
    public func didTapOnPayInvoice(documentID: String?) {
        viewDelegate?.didTapOnPayInvoice()
    }
}
