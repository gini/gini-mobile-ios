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
    var isPayable: Bool { get set }
    /// Stored payment provider for each document/invoice. PaymentComponentsController obtains the payment provider and it's only stored here if the payment provider is installed
    var paymentProvider: PaymentProvider? { get set }
}

/**
 Protocol used to provide updates on the current status of the Payment Components Controller.
 Uses a callback mechanism to handle payment provider requests.
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
     Initializer of the Payment Component Controller class.

     - Parameters:
        - giniHealth: An instance of GiniHealth initialized with GiniHealthAPI.
     - note: Instantiating this class also triggers the loading of available payment providers, which are stored internally for future use.
     - Returns:
        - instance of the payment component controller class
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
     Retrieve the first installed payment provider, if available.
     - Returns: a Payment Provider object.
     */
    public func obtainFirstPaymentProvider() -> PaymentProvider? {
        paymentProviders.first
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
