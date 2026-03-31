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

     - Parameter paymentRequestId: The ID of the created payment request.
     */
    func didCreatePaymentRequest(paymentRequestId: String)

    /**
     Called to determine whether an error should be handled internally by the SDK.
     Return `true` to handle the error internally, or `false` to handle it in the host app.

     - Parameter error: The error to evaluate.
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
       - apiVersion: The API version to use.
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
       - apiVersion: The API version to use.
       - pinningConfig: Configuration for certificate pinning. Format `["PinnedDomains": ["PublicKeyHashes"]]`.
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
       - trackingDelegate: The `GiniHealthTrackingDelegate` that receives event information from the Payment Review screen.
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
     Returns a list of the banking apps supported by the SDK.

     - Parameter completion: A completion callback returning an array of payment providers on success, or an error on failure.
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
     Sets a configuration used to customize the look of the Gini Health SDK, for example to change texts and colors displayed to the user.

     - Parameter configuration: The configuration to set.
     */
    public func setConfiguration(_ configuration: GiniHealthConfiguration) {
        GiniHealthConfiguration.shared = configuration
    }

    /**
     Checks if the document is payable by looking for an IBAN extraction.

     - Parameters:
       - docId: The ID of the uploaded document.
       - completion: A completion callback returning `true` if the document is payable, or an error on failure. Called on the main thread.
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
       - docId: The ID of the uploaded document.
       - completion: A completion callback returning `true` if the document contains multiple invoices, or an error on failure. Called on the main thread.
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
     Fetches a document by its ID.

     - Parameters:
       - docId: The ID of the uploaded document.
       - completion: A completion callback returning the document on success, or an error on failure. Called on the main thread.
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
     Retrieves payment extractions for the given document.

     - Parameters:
       - docId: The ID of the uploaded document.
       - completion: A completion callback returning payment extractions on success, or an error on failure. Called on the main thread.
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
       - docId: The ID of the uploaded document.
       - completion: A completion callback returning all extractions on success, or an error on failure. Called on the main thread.
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
     Creates a payment request.

     - Parameters:
       - paymentInfo: The payment information used to create the request.
       - completion: A completion callback returning the created payment request ID on success, or an error on failure. Called on the main thread.
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
     Deletes a payment request.

     - Parameters:
       - id: The ID of the payment request to delete.
       - completion: A completion callback returning the deleted payment request ID on success, or an error on failure. Called on the main thread.
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
     Deletes a batch of payment requests.

     - Parameters:
       - ids: An array of payment request IDs to delete.
       - completion: A completion callback returning an array of deleted IDs on success, or an error on failure. Called on the main thread.
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
     Opens the selected payment provider app using the given payment request ID and universal link.

     - Parameters:
       - requestID: The ID of the created payment request.
       - universalLink: The universal link for the selected payment provider.
       - urlOpener: The URL opener used to open the link. Defaults to `URLOpener(UIApplication.shared)`.
       - completion: An optional callback invoked after the URL open attempt completes.
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
     Fetches payment extractions for a given document, for use on the payment review screen.

     - Parameters:
       - documentId: The ID of the uploaded document.
       - completion: A completion callback returning an array of payment extractions on success, or an error on failure. Called on the main thread.
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
     Fetches document and payment extractions for the payment review screen.

     - Parameters:
       - documentId: The ID of the uploaded document.
       - completion: A completion callback returning a `DataForReview` value containing the document and extractions on success, or an error on failure. Called on the main thread.
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
       - completion: A completion callback returning the retrieved payment request on success, or an error on failure. Called on the main thread.
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
     Deletes a batch of documents.

     - Parameters:
       - documentIds: An array of document IDs to delete.
       - completion: A completion callback returning a success message on success, or an error on failure. Called on the main thread.
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
     Retrieves the payment associated with the specified payment request.

     - Parameters:
       - id: The ID of the payment request.
       - completion: A completion callback returning the retrieved payment on success, or an error on failure. Called on the main thread.
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

