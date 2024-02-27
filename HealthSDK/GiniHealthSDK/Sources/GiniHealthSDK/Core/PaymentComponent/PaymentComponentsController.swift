//
//  PaymentComponentController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

/**
 Data structure protocol for the stored invoices/documents needed for Payment Component Controller
 */
public protocol GiniDocument {
    /// The document's unique identifier.
    var documentID: String { get set }
    /// The document's amount to pay.
    var amountToPay: String? { get set }
    /// The document's payment due date.
    var paymentDueDate: String? { get set }
    /// The document's recipient name.
    var recipient: String? { get set }
    /// Boolean value that indicates if the document is payable. This is obtained by calling the checkIfDocumentIsPayable method.
    var isPayable: Bool? { get set }
}

/**
 Protocol used to provide updates on the current status of the Payment Components Controller.
 Uses a callback mechanism to handle payment provider requests.
 */
public protocol PaymentComponentsControllerProtocol: AnyObject {
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine, iOS 11 supported
    func didFetchedPaymentProviders()
    func didReceivedErrorOnPaymentProviders(_ error: GiniHealthError)
}

/**
 The `PaymentComponentsController` class allows control over the payment components.
 */
public final class PaymentComponentsController: NSObject {
    /// handling the Payment Component Controller delegate
    public weak var delegate: PaymentComponentsControllerProtocol?
    /// handling the Payment Component view delegate
    public weak var viewDelegate: PaymentComponentViewProtocol?
    /// handling the Payment Bottom view delegate
    public weak var bottomViewDelegate: PaymentProvidersBottomViewProtocol?

    private var giniHealth: GiniHealth
    private var paymentProviders: PaymentProviders = []
    private var installedPaymentProviders: PaymentProviders = []
    
    /// storing the current selected payment provider
    public var selectedPaymentProvider: PaymentProvider?

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
    
    /**
     Retrieve the default installed payment provider, if available.
     - Returns: a Payment Provider object.
     */
    private func obtainDefaultInstalledPaymentProvider() -> PaymentProvider? {
        getDefaultPaymentProvider() ?? installedPaymentProviders.first
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
                self?.checkInstalledPaymentProviders()
                self?.selectedPaymentProvider = self?.obtainDefaultInstalledPaymentProvider()
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
    
    private func storeDefaultPaymentProvider(paymentProvider: PaymentProvider) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(paymentProvider)
            UserDefaults.standard.set(data, forKey: Constants.kDefaultPaymentProvider)
        } catch {
            print("Unable to encode payment provider: (\(error))")
        }
    }
    
    private func getDefaultPaymentProvider() -> PaymentProvider? {
        if let data = UserDefaults.standard.data(forKey: Constants.kDefaultPaymentProvider) {
            do {
                let decoder = JSONDecoder()
                let paymentProvider = try decoder.decode(PaymentProvider.self, from: data)
                return paymentProvider
            } catch {
                print("Unable to decode payment provider: (\(error))")
            }
        }
        return nil
    }
    
    private func checkPaymentProviderIsInstalled(paymentProvider: PaymentProvider?) -> Bool {
        if let appSchemeIOS = paymentProvider?.appSchemeIOS, let url = URL(string: appSchemeIOS) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
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
    public func getPaymentView() -> UIView {
        paymentComponentView = PaymentComponentView()
        let paymentComponentViewModel = PaymentComponentViewModel(paymentProvider: selectedPaymentProvider)
        paymentComponentViewModel.delegate = viewDelegate
        paymentComponentView.viewModel = paymentComponentViewModel
        return paymentComponentView
    }

    public func getPaymentsProvidersBottomViewController() -> UIViewController {
        let paymentProvidersBottomView = PaymentProvidersBottomView()
        let paymentProvidersBottomViewModel = PaymentProvidersBottomViewModel(paymentProviders: paymentProviders,
                                                                              selectedPaymentProvider: selectedPaymentProvider)
        paymentProvidersBottomViewModel.viewDelegate = bottomViewDelegate
        paymentProvidersBottomView.viewModel = paymentProvidersBottomViewModel
        let paymentProvidersBottomViewController = PaymentProvidersBottomViewController()
        paymentProvidersBottomViewController.bottomSheet = paymentProvidersBottomView
        return paymentProvidersBottomViewController
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
                let vc = PaymentReviewViewController.instantiate(with: self.giniHealth, 
                                                                 data: data,
                                                                 selectedPaymentProvider: self.selectedPaymentProvider, 
                                                                 trackingDelegate: trackingDelegate)
                completion(vc, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
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

extension PaymentComponentsController: PaymentProvidersBottomViewProtocol {
    public func didSelectPaymentProvider(paymentProvider: PaymentProvider) {
        selectedPaymentProvider = paymentProvider
        storeDefaultPaymentProvider(paymentProvider: paymentProvider)
        bottomViewDelegate?.didSelectPaymentProvider(paymentProvider: paymentProvider)
    }
    
    public func didTapOnClose() {
        bottomViewDelegate?.didTapOnClose()
    }
}

extension PaymentComponentsController {
    private enum Constants {
        static let kDefaultPaymentProvider = "defaultPaymentProvider"
    }
}
