//
//  GiniHealth.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary
import GiniUtilites
import GiniInternalPaymentSDK

/**
 Delegate to inform about the current status of the Gini Health SDK.
 Makes use of callback for handling payment request creation.
 
 */
public protocol GiniHealthDelegate: AnyObject {
    
    /**
     Called when the payment request was successfully created.
     - Parameter paymentRequestId: Id of the created payment request.
     */
    func didCreatePaymentRequest(paymentRequestId: String)
    
    /**
     Error handling. If delegate is set and error is going to be handled internally the method should return `true`.
     If error handling is planned to be custom, return `false` for specific error cases.
     - Parameter error: The error which will be handled.
     */
    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool
    
    /**
     Called when the Gini Health SDK has been dismissed.
     */
    func didDismissHealthSDK()
}
/**
 Errors thrown with Gini Health SDK.
 */
public enum GiniHealthError: Error {
     /** Error thrown when there are no apps which supports Gini Pay Connect installed. */
    case noInstalledApps
     /** Error thrown when api returns failure. */
    case apiError(GiniError)
    /** Error thrown when api didn't returns payment extractions. */
    case noPaymentDataExtracted
}

extension GiniHealthError: Equatable {}
/**
 Data structure for Payment Review Screen initialization.
 */
public struct DataForReview {
    /** The document to be reviewed. */
    public let document: Document
    /** The extractions associated with the document. */
    public let extractions: [Extraction]
    /**
     Creates a new data structure for the Payment Review screen.
     - Parameters:
       - document: The document to be reviewed.
       - extractions: The extractions associated with the document.
     */
    public init(document: Document, extractions: [Extraction]) {
        self.document = document
        self.extractions = extractions
    }
}
/**
 Core class for Gini Health SDK.
 */
@objc public final class GiniHealth: NSObject {
    /** reponsible for interaction with Gini Health backend . */
    public var giniApiLib: GiniHealthAPI
    /** reponsible for the whole document processing. */
    public var documentService: DefaultDocumentService
    /** reponsible for the payment processing. */
    public var paymentService: PaymentService
    /** responsible for the client configuration processing */
    public var clientConfigurationService: ClientConfigurationServiceProtocol?
    /** delegate to inform about the current status of the Gini Health SDK. */
    public weak var delegate: GiniHealthDelegate?
    /** delegate to inform about the changes into PaymentComponentsController */
    public weak var paymentDelegate: PaymentComponentsControllerProtocol?

    private var bankProviders: [PaymentProvider] = []

    /** Configuration for the payment component, controlling its branding and display options. */
    public var paymentComponentConfiguration: PaymentComponentConfiguration = PaymentComponentConfiguration(showPaymentComponentInOneRow: false,
                                                                                                            hideInfoForReturningUser: (GiniHealthConfiguration.shared.showPaymentReviewScreen ? false : true))
    /** The client configuration used for customizing SDK behavior. */
    public var clientConfiguration: ClientConfiguration? = GiniHealthConfiguration.shared.clientConfiguration
    /** The controller responsible for managing payment component presentation and lifecycle. */
    public var paymentComponentsController: PaymentComponentsController!

    /**
     Initializes a new instance of GiniHealth.

     This initializer creates a GiniHealth instance by first constructing a Client object with the provided client credentials (id, secret, domain)

     - Parameters:
     - id: The client ID provided by Gini when you register your application. This is a unique identifier for your application.
     - secret: The client secret provided by Gini alongside the client ID. This is used to authenticate your application to the Gini API.
     - domain: The domain associated with your client credentials. This is used to scope the client credentials to a specific domain.
     - logLevel: The log level. `LogLevel.none` by default.
     */
    public init(id: String,
                secret: String,
                domain: String,
                apiVersion: Int = Constants.defaultVersionAPI,
                logLevel: LogLevel = .none) {
        let client = Client(id: id, secret: secret, domain: domain)
        self.giniApiLib = GiniHealthAPI.Builder(client: client, api: .default, logLevel: logLevel.toHealthLogLevel()).build()
        self.documentService = DefaultDocumentService(docService: giniApiLib.documentService())
        self.paymentService = giniApiLib.paymentService(apiDomain: APIDomain.default, apiVersion: apiVersion)
        self.clientConfigurationService = giniApiLib.clientConfigurationService()
        super.init()
        self.paymentComponentsController = PaymentComponentsController(giniHealth: self)
        self.paymentComponentsController.delegate = self
    }
    
    /**
     Initializes a new instance of GiniHealth.
     
     This initializer creates a GiniHealth instance by first constructing a Client object with the provided client credentials (id, secret, domain)
     
     - Parameters:
     - id: The client ID provided by Gini when you register your application. This is a unique identifier for your application.
     - secret: The client secret provided by Gini alongside the client ID. This is used to authenticate your application to the Gini API.
     - domain: The domain associated with your client credentials. This is used to scope the client credentials to a specific domain.
     - pinningConfig: Configuration for certificate pinning. Format ["PinnedDomains" : ["PublicKeyHashes"]]
     - logLevel: The log level. `LogLevel.none` by default.
     */
    public init(id: String,
                secret: String,
                domain: String,
                apiVersion: Int = Constants.defaultVersionAPI,
                pinningConfig: [String: [String]],
                logLevel: LogLevel = .none) {
        let client = Client(id: id, secret: secret, domain: domain, apiVersion: apiVersion)
        self.giniApiLib = GiniHealthAPI.Builder(client: client,
                                                pinningConfig: pinningConfig,
                                                logLevel: logLevel.toHealthLogLevel()).build()
        self.documentService = DefaultDocumentService(docService: giniApiLib.documentService())
        self.paymentService = giniApiLib.paymentService(apiDomain: APIDomain.default, apiVersion: apiVersion)
        self.clientConfigurationService =  giniApiLib.clientConfigurationService()
        super.init()
        self.paymentComponentsController = PaymentComponentsController(giniHealth: self)
        self.paymentComponentsController.delegate = self
    }

    /**
     Initializes a new instance of GiniHealth.

     - Parameter giniApiLib: The GiniHealthAPI instance used for document and payment services.
     */
    public init(giniApiLib: GiniHealthAPI) {
        self.giniApiLib = giniApiLib
        self.documentService = DefaultDocumentService(docService: giniApiLib.documentService())
        self.paymentService = giniApiLib.paymentService(apiDomain: .default, apiVersion: Constants.defaultVersionAPI)
        self.clientConfigurationService =  giniApiLib.clientConfigurationService()
        super.init()
        self.paymentComponentsController = PaymentComponentsController(giniHealth: self)
        self.paymentComponentsController.delegate = self
    }
    
    /**
     Initiates the payment flow for a specified document and payment information.
     - Parameters:
       - documentId: An optional identifier for the document associated with the payment flow.
       - paymentInfo: An optional `PaymentInfo` object containing the payment details.
       - navigationController: The `UINavigationController` used to present subsequent view controllers in the payment flow.
       - trackingDelegate: The `GiniHealthTrackingDelegate` provides event information that happens on the Payment Review screen.
     */
    public func startPaymentFlow(documentId: String?, paymentInfo: GiniHealthSDK.PaymentInfo?, navigationController: UINavigationController, trackingDelegate: GiniHealthTrackingDelegate?) {
        paymentComponentsController.startPaymentFlow(documentId: documentId, paymentInfo: paymentInfo, navigationController: navigationController, trackingDelegate: trackingDelegate)
    }
    
    /**
     Fetches bank logos for the available payment providers.

     - Returns: A tuple containing an array of logo data and the count of additional banks, if any.
     */
    public func fetchBankLogos() -> (logos: [Data]?, additionalBankCount: Int?) {
        return paymentComponentsController.fetchBankLogos()
    }

    /**
     Getting a list of the banking apps supported by SDK
     
     - Parameters:
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater.
     Result is a value that represents either a success or a failure, including an associated value in each case.
     In success case it includes array of payment providers supported by SDK.
     In case of failure error provided by API.
     */
    
    public func fetchBankingApps(completion: @escaping (Result<PaymentProviders, GiniError>) -> Void) {
        paymentService.paymentProviders { [weak self] result in
            guard let self = self else {
                completion(.failure(GiniError.toGiniHealthSDKError(error: .requestCancelled)))
                return
            }
            switch result {
            case let .success(providers):
                self.bankProviders = providers.map { PaymentProvider(healthPaymentProvider: $0) }
                completion(.success(self.bankProviders))
            case let .failure(error):
                completion(.failure(GiniError.toGiniHealthSDKError(error: error)))
            }
        }
    }
    
    /**
     Sets a configuration which is used to customize the look of the Gini Health SDK,
     for example to change texts and colors displayed to the user.
     
     - Parameters:
        - configuration: The configuration to set.
     
     */
    public func setConfiguration(_ configuration: GiniHealthConfiguration) {
        GiniHealthConfiguration.shared = configuration
    }

    /**
    Checks if the document is payable, looks for iban extraction.

    - Parameters:
       - docId: Id of uploaded document.
       - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. Completion block called on main thread.
       In success case it includes a boolean value and returns true if paymentState is payable.
       In case of failure in case of failure error from the server side.

    */
   public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
       documentService.fetchDocument(with: docId) { [weak self] result in
           guard let self = self else {
               completion(.failure(.apiError(GiniError.toGiniHealthSDKError(error: .requestCancelled))))
               return
           }
           switch result {
           case let .success(createdDocument):
               self.documentService.extractions(for: createdDocument,
                                                cancellationToken: CancellationToken()) { result in
                   DispatchQueue.main.async {
                       switch result {
                       case let .success(extractionResult):
                               if let paymentStateExtraction = extractionResult.extractions.first(where: { $0.name == ExtractionType.paymentState.rawValue })?.value, paymentStateExtraction == PaymentState.payable.rawValue {
                               completion(.success(true))
                           } else {
                               completion(.success(false))
                           }
                       case .failure(let error):
                           completion(.failure(.apiError(error)))
                       }
                   }
               }
           case .failure(let error):
               completion(.failure(.apiError(error)))
           }
       }
   }

    /**
    Checks if the document contains multiple invoices.

    - Parameters:
       - docId: Id of uploaded document.
       - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. Completion block called on main thread.
       In success case it includes a boolean value and returns true if contains multiple documents is true or false
       In case of failure in case of failure error from the server side.

    */
    public func checkIfDocumentContainsMultipleInvoices(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        documentService.fetchDocument(with: docId) { [weak self] result in
            guard let self = self else {
                completion(.failure(.apiError(GiniError.toGiniHealthSDKError(error: .requestCancelled))))
                return
            }
            switch result {
            case let .success(createdDocument):
                self.documentService.extractions(for: createdDocument,
                                                 cancellationToken: CancellationToken()) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(extractionResult):
                                if let containsMultipleDocsExtraction = extractionResult.extractions.first(where: { $0.name == ExtractionType.containsMultipleDocs.rawValue })?.value, containsMultipleDocsExtraction == Constants.hasMultipleDocuments {
                                completion(.success(true))
                            } else {
                                completion(.success(false))
                            }
                        case .failure(let error):
                            completion(.failure(.apiError(error)))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(.apiError(error)))
            }
        }
    }

    /**
     Polls the document via document id.
     
     - Parameters:
        - docId: Id of uploaded document.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success returns the polled document.
        In case of failure error from the server side.

     */
    public func pollDocument(docId: String, completion: @escaping (Result<Document, GiniHealthError>) -> Void){
        documentService.fetchDocument(with: docId) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(document):
                    completion(.success(document))
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
    
    /**
     Retrieves extractions for the given document.
     - Parameters:
       - docId: Id of the uploaded document.
       - completion: A completion callback called on the main thread. Returns an array of extractions on success, or an error on failure.
     */
    public func getExtractions(docId: String, completion: @escaping (Result<[Extraction], GiniHealthError>) -> Void) {
        documentService.fetchDocument(with: docId) { [weak self] result in
            guard let self = self else {
                completion(.failure(.apiError(GiniError.toGiniHealthSDKError(error: .requestCancelled))))
                return
            }
            switch result {
            case let .success(createdDocument):
                self.documentService
                        .extractions(for: createdDocument,
                                     cancellationToken: CancellationToken()) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case let .success(extractionResult):
                                    if let paymentExtractionsContainer = extractionResult.payment, let paymentExtractions = paymentExtractionsContainer.first {
                                        completion(.success(paymentExtractions))
                                    } else {
                                        completion(.failure(.noPaymentDataExtracted))
                                    }
                                case let .failure(error):
                                    completion(.failure(.apiError(error)))
                                }
                            }
                        }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }

    /**
     Retrieves all extractions for the given document, including medical information.
     - Parameters:
       - docId: Id of the uploaded document.
       - completion: A completion callback called on the main thread. Returns an array of all extractions on success, or an error on failure.
     */
    public func getAllExtractions(docId: String, completion: @escaping (Result<[Extraction], GiniHealthError>) -> Void) {
        documentService.fetchDocument(with: docId) { [weak self] result in
            guard let self = self else {
                completion(.failure(.apiError(GiniError.toGiniHealthSDKError(error: .requestCancelled))))
                return
            }
            switch result {
            case let .success(createdDocument):
                self.documentService
                        .extractions(for: createdDocument,
                                     cancellationToken: CancellationToken()) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case let .success(extractionResult):
                                    completion(.success(extractionResult.extractions))
                                case let .failure(error):
                                    completion(.failure(.apiError(error)))
                                }
                            }
                        }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }

    /**
     Creates a payment request
     
     - Parameters:
        - paymentInfo: Model object for payment information.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success it includes the id of created payment request.
        In case of failure error from the server side.
     
     */
    public func createPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo, completion: @escaping (Result<String, GiniError>) -> Void) {
        paymentService.createPaymentRequest(sourceDocumentLocation: paymentInfo.sourceDocumentLocation,
                                            paymentProvider: paymentInfo.paymentProviderId,
                                            recipient: paymentInfo.recipient,
                                            iban: paymentInfo.iban,
                                            amount: paymentInfo.amount,
                                            purpose: paymentInfo.purpose) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(requestId):
                    completion(.success(requestId))
                case let .failure(error):
                    completion(.failure(GiniError.toGiniHealthSDKError(error: error)))
                }
            }
        }
    }
    
    /**
     Deletes a payment request
     
     - Parameters:
        - id: Id of the payment request to delete.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success it includes the id of deleted payment request.
        In case of failure error from the server side.
     
     */
    public func deletePaymentRequest(id: String, completion: @escaping (Result<String, GiniError>) -> Void) {
        paymentService.deletePaymentRequest(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(requestId):
                    completion(.success(requestId))
                case let .failure(error):
                    completion(.failure(GiniError.toGiniHealthSDKError(error: error)))
                }
            }
        }
    }
    
    /**
     Deletes a batch of payment request
     
     - Parameters:
        - ids: An array of paymen request ids to be deleted
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success it includes an array of deleted ids
        In case of failure error from the server side.
     
     */
    public func deletePaymentRequests(ids: [String], completion: @escaping (Result<[String], GiniError>) -> Void) {
        paymentService.deletePaymentRequests(ids) { result in
            DispatchQueue.main.async {
                switch result {
                    case let .success(deletedIds):
                        completion(.success(deletedIds))
                    case let .failure(error):
                        completion(.failure(GiniError.toGiniHealthSDKError(error: error)))
                }
            }
        }
    }
    
    /**
     Opens an app of selected payment provider.
        openUrl called on main thread.
     
     - Parameters:
        - requestId: Id of the created payment request.
        - universalLink: Universal link for the selected payment provider
     */
    public func openPaymentProviderApp(requestID: String, universalLink: String, urlOpener: URLOpener = URLOpener(UIApplication.shared), completion: GiniOpenLinkCompletionBlock? = nil) {
        let queryItems = [URLQueryItem(name: "id", value: requestID)]
        let urlString = universalLink + "://payment"
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = queryItems
        let resultUrl = urlComponents.url!
        DispatchQueue.main.async {
            urlOpener.openLink(url: resultUrl, completion: completion)
        }
    }
    
    /**
     Sets a data for payment review screen
     
     - Parameters:
        - documentId: Id of uploaded document.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater.
        Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success it includes array of extractions.
        In case of failure error from the server side.
     
     */
    public func setDocumentForReview(documentId: String, completion: @escaping (Result<[Extraction], GiniHealthError>) -> Void) {
        documentService.fetchDocument(with: documentId) { [weak self] result in
            guard let self = self else {
                completion(.failure(.apiError(GiniError.toGiniHealthSDKError(error: .requestCancelled))))
                return
            }
            switch result {
            case .success(let document):
                self.getExtractions(docId: document.id) { result in
                    switch result{
                    case .success(let extractions):
                        completion(.success(extractions))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
    
    /**
     Fetches document and extractions for payment review screen
     
     - Parameters:
        - documentId: Id of uploaded document.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater.
        Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success returns DataForReview structure. It includes document and array of extractions.
        In case of failure error from the server side and nil instead of document .

     */
    public func fetchDataForReview(documentId: String, completion: @escaping (Result<DataForReview, GiniHealthError>) -> Void) {
        documentService.fetchDocument(with: documentId) { [weak self] result in
            guard let self = self else {
                completion(.failure(.apiError(GiniError.toGiniHealthSDKError(error: .requestCancelled))))
                return
            }
            switch result {
            case let .success(document):
                self.documentService
                    .extractions(for: document,
                                 cancellationToken: CancellationToken()) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case let .success(extractionResult):
                                if let paymentExtractionsContainer = extractionResult.payment, let paymentExtractions = paymentExtractionsContainer.first {
                                    let fetchedData = DataForReview(document: document, extractions: paymentExtractions)
                                    completion(.success(fetchedData))
                                } else {
                                    completion(.failure(.noPaymentDataExtracted))
                                }
                            case let .failure(error):
                                completion(.failure(.apiError(error)))
                            }
                        }
                    }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
    
    /**
     Retrieves a payment request by ID.
     - Parameters:
       - id: The ID of the payment request to retrieve.
       - completion: A completion callback called on the main thread. Returns the retrieved payment request on success, or an error on failure.
     */
    public func getPaymentRequest(by id: String,
                                  completion: @escaping (Result<PaymentRequest, GiniError>) -> Void) {
        paymentService.paymentRequest(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(paymentRequest):
                    completion(.success(paymentRequest))
                case let .failure(error):
                    completion(.failure(GiniError.toGiniHealthSDKError(error: error)))
                }
            }
        }
    }

    /**
     Delete a batch of documents

     - Parameters:
        - documentIds: An array of document ids to be deleted
        - completion: An action for deleting a batch of documents. Result is a value that represents either a success or a failure, including an associated value in each case.
        In success it includes a success message
        In case of failure error from the server side.

     */
    public func deleteDocuments(documentIds: [String],
                                completion: @escaping (Result<String, GiniError>) -> Void) {
        documentService.deleteDocuments(documentIds) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(message):
                    completion(.success(message))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /**
     Retrieve a `Payment` of the specified `PaymentRequest`

     - Parameters:
        - id: The `id` of the payment request to retrieve the payment.
        - completion: An action for retrieving the payment. Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success, it includes the retrieved payment.
        In case of failure, error from the server side.
     */

    public func getPayment(id: String,
                           completion: @escaping (Result<Payment, GiniError>) -> Void) {
        paymentService.payment(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(payment):
                    completion(.success(payment))
                case let .failure(error):
                    completion(.failure(GiniError.toGiniHealthSDKError(error: error)))
                }
            }
        }
    }

    /** A static string representing the current version of the Gini Health SDK. */
    public static var versionString: String {
        return GiniHealthSDKVersion
    }
}

extension GiniHealth: PaymentComponentsControllerProtocol {
    public func isLoadingStateChanged(isLoading: Bool) {
        paymentDelegate?.isLoadingStateChanged(isLoading: isLoading)
    }
    
    public func didFetchedPaymentProviders() {
        paymentDelegate?.didFetchedPaymentProviders()
    }
    
    public func didDismissPaymentComponents() {
        delegate?.didDismissHealthSDK()
    }
}

extension GiniHealth {
    /** Constants used by the Gini Health SDK. */
    public enum Constants {
        /** The default API version used when no version is specified. */
        public static let defaultVersionAPI = 5
        static let hasMultipleDocuments = "true"
    }
}

