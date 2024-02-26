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
}

public protocol PaymentComponentsControllerProtocol: AnyObject {
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine, iOS 11 supported
    func didFetchedPaymentProviders()
    func didReceivedErrorOnPaymentProviders(_ error: GiniHealthError)
}

public final class PaymentComponentsController: NSObject {
    public weak var delegate: PaymentComponentsControllerProtocol?
    public weak var viewDelegate: PaymentComponentViewProtocol?

    private var giniHealth: GiniHealth
    private var paymentProviders: PaymentProviders = []
    private var installedPaymentProviders: PaymentProviders = []
    
    public var selectedPaymentProvider: PaymentProvider?
    
    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }

    var paymentComponentView: PaymentComponentView!

    public init(giniHealth: GiniHealth) {
        self.giniHealth = giniHealth
        super.init()
        setupListeners()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupListeners() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    public func loadPaymentProviders() {
        self.isLoading = true
        self.giniHealth.fetchBankingApps { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(paymentProviders):
                self?.paymentProviders = paymentProviders
                self?.checkInstalledPaymentProviders()
                self?.selectedPaymentProvider = self?.obtainFirstInstalledPaymentProvider()
                self?.delegate?.didFetchedPaymentProviders()
            case let .failure(error):
                print("Couldn't load payment providers: \(error.localizedDescription)")
            }
        }
    }
    
    @objc
    private func willEnterForeground() {
        if !checkPaymentProviderIsInstalled(paymentProvider: selectedPaymentProvider) {
            loadPaymentProviders()
        }
    }
    
    private func checkInstalledPaymentProviders() {
        installedPaymentProviders = []
        for paymentProvider in paymentProviders {
            if checkPaymentProviderIsInstalled(paymentProvider: paymentProvider) {
                self.installedPaymentProviders.append(paymentProvider)
            }
        }
    }
    
    private func checkPaymentProviderIsInstalled(paymentProvider: PaymentProvider?) -> Bool {
        if let appSchemeIOS = paymentProvider?.appSchemeIOS, let url = URL(string: appSchemeIOS) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    private func obtainFirstInstalledPaymentProvider() -> PaymentProvider? {
        installedPaymentProviders.first
    }

    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        giniHealth.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    public func getPaymentView() -> UIView {
        paymentComponentView = PaymentComponentView()
        let paymentComponentViewModel = PaymentComponentViewModel(paymentProvider: selectedPaymentProvider)
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
