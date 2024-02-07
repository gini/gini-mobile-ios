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
    /// Store payment provider for each document/invoice. Payment provider is obtained by PaymentComponentsController and it's only stored here if the payment provider is installed
    var paymentProvider: PaymentProvider? { get set }
}

/**
 Delegate to inform about the current status of the Payment Components Controller.
 Makes use of callback for handling payment providers request.
 */
public protocol PaymentComponentsControllerProtocol: AnyObject {
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine, iOS 11 supported
    func didFetchedPaymentProviders(_ paymentProviders: PaymentProviders)
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

    private var giniHealth: GiniHealth
    private var paymentProviders: PaymentProviders = []

    /**
     Returns a Payment Component Controller instance
     - parameter giniHealth: GiniHealth initialized with GiniHealthAPI

     - note: Also, instantiating of this class do load the payment providers available and stores them internally for later use.
     */
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

    /// reponsible for storing the loading state of the controller and passing it to the delegate listeners
    private var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }

    /**
     Returing the first payment provider installed if is available and installed
     - Returns: a Payment Provider object.
     */
    public func obtainFirstPaymentProvider() -> PaymentProvider? {
        paymentProviders.first
    }

    /**
     Checks if the document is payable which looks for iban extraction.

     - Parameters:
        - docId: Id of uploaded document.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. Completion block called on main thread.
        In success case it includes a boolean value and returns true if iban was extracted.
        In case of failure in case of failure error from the server side.
     */
    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        giniHealth.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    /**
     Provides a custom Gini view that contains more information, bank selection if available and a tappable button to pay the document/invoice

     - Parameters:
        - paymentProvider: A Payment Provider object if is available and installed
     - Returns: an custom view
     */
    public func getPaymentView(paymentProvider: PaymentProvider?) -> UIView {
        let paymentComponentView = PaymentComponentView()
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
