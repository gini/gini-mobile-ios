//
//  PaymentComponentController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary
/**
 Protocol used to provide updates on the current status of the Payment Components Controller.
 Uses a callback mechanism to handle payment provider requests.
 */
public protocol PaymentComponentsControllerProtocol: AnyObject {
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine
    func didFetchedPaymentProviders()
}

protocol PaymentComponentsProtocol {
    var isLoading: Bool { get set }
    var selectedPaymentProvider: PaymentProvider? { get set }
    func loadPaymentProviders()
    func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void)
    func paymentView(documentId: String) -> UIView
    func bankSelectionBottomSheet() -> UIViewController
    func loadPaymentReviewScreenFor(documentID: String, trackingDelegate: GiniHealthTrackingDelegate?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void)
    func paymentInfoViewController() -> UIViewController
}

/**
 The `PaymentComponentsController` class allows control over the payment components.
 */
public final class PaymentComponentsController: PaymentComponentsProtocol {
    /// handling the Payment Component Controller delegate
    public weak var delegate: PaymentComponentsControllerProtocol?
    /// handling the Payment Component view delegate
    public weak var viewDelegate: PaymentComponentViewProtocol?
    /// handling the Payment Bottom view delegate
    public weak var bottomViewDelegate: PaymentProvidersBottomViewProtocol?

    private var giniHealth: GiniHealth
    private let giniHealthConfiguration = GiniHealthConfiguration.shared
    private var paymentProviders: PaymentProviders = []
    
    /// storing the current selected payment provider
    public var selectedPaymentProvider: PaymentProvider?

    /// Payment Component View Configuration
    public var paymentComponentConfiguration: PaymentComponentConfiguration?

    /// reponsible for storing the loading state of the controller and passing it to the delegate listeners
    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }
    
    var paymentComponentView: PaymentComponentView!

    /**
     Initializer of the Payment Component Controller class.

     - Parameters:
        - giniHealth: An instance of GiniHealth initialized with GiniHealthAPI.
     - Returns:
        - instance of the payment component controller class
     */
    public init(giniHealth: GiniHealth) {
        self.giniHealth = giniHealth
    }
    
    /**
     Retrieves the default installed payment provider, if available.
     - Returns: a Payment Provider object.
     */
    private func defaultInstalledPaymentProvider() -> PaymentProvider? {
        savedPaymentProvider()
    }
    
    /**
     Loads the payment providers list and stores them.
     - note: Also triggers a function that checks if the payment providers are installed.
     */
    public func loadPaymentProviders() {
        self.isLoading = true
        self.giniHealth.fetchBankingApps { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(paymentProviders):
                self?.paymentProviders = paymentProviders
                self?.selectedPaymentProvider = self?.defaultInstalledPaymentProvider()
                self?.delegate?.didFetchedPaymentProviders()
            case let .failure(error):
                print("Couldn't load payment providers: \(error.localizedDescription)")
            }
        }
    }
    
    private func storeDefaultPaymentProvider(paymentProvider: PaymentProvider) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(paymentProvider)
            UserDefaults.standard.set(data, forKey: Constants.kDefaultPaymentProvider)
        } catch {
            print("Unable to encode payment provider: (\(error))")
        }
    }
    
    private func savedPaymentProvider() -> PaymentProvider? {
        if let data = UserDefaults.standard.data(forKey: Constants.kDefaultPaymentProvider) {
            do {
                let decoder = JSONDecoder()
                let paymentProvider = try decoder.decode(PaymentProvider.self, from: data)
                if self.paymentProviders.contains(where: { $0.id == paymentProvider.id }) {
                    return paymentProvider
                }
            } catch {
                print("Unable to decode payment provider: (\(error))")
            }
        }
        return nil
    }

    /**
     Checks if the document is payable by extracting the IBAN.
     - Parameters:
         - docId: The ID of the uploaded document.
         - completion: A closure for processing asynchronous data received from the service. It has a Result type parameter, representing either success or failure. The completion block is called on the main thread.
         In the case of success, it includes a boolean value indicating whether the IBAN was extracted successfully.
         In case of failure, it returns an error from the server side.
     */
    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        giniHealth.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    /**
     Provides a custom Gini view that contains more information, bank selection if available and a tappable button to pay the document/invoice

     - Parameters:
     - Returns: a custom view
     */
    public func paymentView(documentId: String) -> UIView {
        paymentComponentView = PaymentComponentView()
        let paymentComponentViewModel = PaymentComponentViewModel(paymentProvider: selectedPaymentProvider, giniHealthConfiguration: giniHealthConfiguration, paymentComponentConfiguration: paymentComponentConfiguration)
        paymentComponentViewModel.delegate = viewDelegate
        paymentComponentViewModel.documentId = documentId
        paymentComponentView.viewModel = paymentComponentViewModel
        return paymentComponentView
    }

    public func bankSelectionBottomSheet() -> UIViewController {
        let paymentProvidersBottomViewModel = BanksBottomViewModel(paymentProviders: paymentProviders,
                                                                   selectedPaymentProvider: selectedPaymentProvider)
        let paymentProvidersBottomView = BanksBottomView(viewModel: paymentProvidersBottomViewModel)
        paymentProvidersBottomViewModel.viewDelegate = self
        paymentProvidersBottomView.viewModel = paymentProvidersBottomViewModel
        return paymentProvidersBottomView
    }
    
    public func loadPaymentReviewScreenFor(documentID: String, trackingDelegate: GiniHealthTrackingDelegate?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void) {
        self.isLoading = true
        self.giniHealth.fetchDataForReview(documentId: documentID) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let data):
                guard let self else {
                    completion(nil, nil)
                    return
                }
                guard let selectedPaymentProvider else {
                    completion(nil, nil)
                    return
                }
                let vc = PaymentReviewViewController.instantiate(with: self.giniHealth,
                                                                 data: data,
                                                                 selectedPaymentProvider: selectedPaymentProvider,
                                                                 trackingDelegate: trackingDelegate)
                completion(vc, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func paymentInfoViewController() -> UIViewController {
        let paymentInfoViewController = PaymentInfoViewController()
        let paymentInfoViewModel = PaymentInfoViewModel(paymentProviders: paymentProviders)
        paymentInfoViewController.viewModel = paymentInfoViewModel
        return paymentInfoViewController
    }
}

extension PaymentComponentsController: PaymentComponentViewProtocol {
    public func didTapOnMoreInformation(documentId: String?) {
        viewDelegate?.didTapOnMoreInformation()
    }
    
    public func didTapOnBankPicker(documentId: String?) {
        viewDelegate?.didTapOnBankPicker()
    }
    
    public func didTapOnPayInvoice(documentId: String?) {
        viewDelegate?.didTapOnPayInvoice()
    }
}

extension PaymentComponentsController: PaymentProvidersBottomViewProtocol {
    public func didSelectPaymentProvider(paymentProvider: PaymentProvider) {
        selectedPaymentProvider = paymentProvider
        storeDefaultPaymentProvider(paymentProvider: paymentProvider)
        bottomViewDelegate?.didSelectPaymentProvider(paymentProvider: paymentProvider)
    }
    
    public func didTapOnClose() {
        bottomViewDelegate?.didTapOnClose()
    }
    
    public func didTapOnMoreInformation() {
        viewDelegate?.didTapOnMoreInformation()
    }
}

extension PaymentComponentsController {
    private enum Constants {
        static let kDefaultPaymentProvider = "defaultPaymentProvider"
    }
}
