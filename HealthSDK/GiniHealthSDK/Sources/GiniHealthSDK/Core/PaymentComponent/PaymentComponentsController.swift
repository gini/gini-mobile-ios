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
    var isPayable: Bool? { get set }
    var paymentProvider: PaymentProvider? { get set }
}

public protocol PaymentComponentsControllerProtocol: AnyObject, PaymentComponentViewModelProtocol {
    func didTapOnMoreInformations(documentID: String?)
    func didTapOnBankPicker(documentID: String?)
    func didTapOnPayInvoice(documentID: String?)
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine, iOS 11 supported
}

extension PaymentComponentsControllerProtocol {
    public func didTapOnMoreInformations() {
        didTapOnMoreInformations(documentID: nil)
    }
    public func didTapOnBankPicker() {
        didTapOnBankPicker(documentID: nil)
    }
    public func didTapOnPayInvoice() {
        didTapOnPayInvoice(documentID: nil)
    }
}

public final class PaymentComponentsController: NSObject, PaymentComponentsControllerProtocol {

    public weak var delegate: PaymentComponentsControllerProtocol?

    private var giniHealth: GiniHealth
    private var paymentProviders: PaymentProviders = []

    public init(giniHealth: GiniHealth) {
        self.giniHealth = giniHealth
    }

    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }

    var paymentComponentView: PaymentComponentView!

    public func getPaymentProviders(completion: @escaping (Result<PaymentProviders, GiniHealthError>) -> Void) {
        giniHealth.checkIfAnyPaymentProviderAvailable { [weak self] result in
            switch result {
            case let .success(providers):
                self?.paymentProviders = []
                for provider in providers {
                    if let url = URL(string: provider.appSchemeIOS), UIApplication.shared.canOpenURL(url) {
                        self?.paymentProviders.append(provider)
                    }
                }
            case .failure(_):
               break
            }
            completion(result)
        }
    }

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
        paymentComponentViewModel.delegate = delegate
        paymentComponentView.viewModel = paymentComponentViewModel
        return paymentComponentView
    }
}

extension PaymentComponentsController: PaymentComponentViewModelProtocol {
    public func didTapOnMoreInformations(documentID: String?) {
        delegate?.didTapOnMoreInformations()
    }
    
    public func didTapOnBankPicker(documentID: String?) {
        delegate?.didTapOnBankPicker()
    }
    
    public func didTapOnPayInvoice(documentID: String?) {
        delegate?.didTapOnPayInvoice()
    }

    public func isLoadingStateChanged(isLoading: Bool) {
        delegate?.isLoadingStateChanged(isLoading: isLoading)
    }
}
