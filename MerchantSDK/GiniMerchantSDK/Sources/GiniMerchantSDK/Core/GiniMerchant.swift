//
//  GiniMerchant.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary
import GiniUtilites

/**
 Delegate to inform about the current status of the Gini Merchant SDK.
 Makes use of callback for handling payment request creation.
 
 */
public protocol GiniMerchantDelegate: AnyObject {
    
    /**
     Called when the payment request was successfully created
     
     - parameter paymentRequestID: Id of created payment request.
     */
    func didCreatePaymentRequest(paymentRequestID: String)
    
    /**
     Error handling. If delegate is set and error is going to  be handled internally the method should return true.
     If error hadling is planned to be custom return false for specific error case.
     
     - parameter error: error which will be handled.
     */
    func shouldHandleErrorInternally(error: GiniMerchantError) -> Bool
}
/**
 Errors thrown with Gini Merchant SDK.
 */
public enum GiniMerchantError: Error {
     /// Error thrown when there are no apps which supports Gini Pay Connect installed.
    case noInstalledApps
     /// Error thrown when api returns failure.
    case apiError(GiniError)
    /// Error thrown when api didn't returns payment extractions.
    case noPaymentDataExtracted
}

extension GiniMerchantError: Equatable {}
/**
 Data structure for Payment Review Screen initialization.
 */
public struct DataForReview {
    public let document: Document
    public let extractions: [Extraction]
    public init(document: Document, extractions: [Extraction]) {
        self.document = document
        self.extractions = extractions
    }
}
/**
 Core class for Gini Merchant SDK.
 */
@objc public final class GiniMerchant: NSObject {
    /// reponsible for interaction with Gini Health backend .
    public var giniApiLib: GiniHealthAPI
    /// reponsible for the whole document processing.
    public var documentService: DefaultDocumentService
    /// reponsible for the payment processing.
    public var paymentService: PaymentService
    /// delegate to inform about the current status of the Gini Merchant SDK.
    public weak var delegate: GiniMerchantDelegate?
   
    private var bankProviders: [PaymentProvider] = []

    /**
     Initializes a new instance of GiniMerchant.
     
     This initializer creates a GiniMerchant instance by first constructing a Client object with the provided client credentials (id, secret, domain)
     
     - Parameters:
     - id: The client ID provided by Gini when you register your application. This is a unique identifier for your application.
     - secret: The client secret provided by Gini alongside the client ID. This is used to authenticate your application to the Gini API.
     - domain: The domain associated with your client credentials. This is used to scope the client credentials to a specific domain.
     - logLevel: The log level. `LogLevel.none` by default.
     */
    public init(id: String, 
                secret: String,
                domain: String,
                apiVersion: Int = Constants.merchantVersionAPI,
                logLevel: LogLevel = .none) {
        let client = Client(id: id, secret: secret, domain: domain, apiVersion: apiVersion)
        self.giniApiLib = GiniHealthAPI.Builder(client: client, api: .merchant, logLevel: logLevel.toHealthLogLevel()).build()
        self.documentService = DefaultDocumentService(docService: giniApiLib.documentService())
        self.paymentService = giniApiLib.paymentService(apiDomain: APIDomain.merchant, apiVersion: apiVersion)
    }
    
    /**
     Initializes a new instance of GiniMerchant.
     
     This initializer creates a GiniMerchant instance by first constructing a Client object with the provided client credentials (id, secret, domain)
     
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
                                                logLevel: logLevel.toHealthLogLevel(),
                                                sessionDelegate: GiniSessionDelegate(pinningConfig: pinningConfig)).build()
        self.documentService = DefaultDocumentService(docService: giniApiLib.documentService())
        self.paymentService = giniApiLib.paymentService(apiDomain: APIDomain.merchant, apiVersion: apiVersion)
    }

    //For Testing
    internal init(giniApiLib: GiniHealthAPI) {
        self.giniApiLib = giniApiLib
        self.documentService = DefaultDocumentService(docService: giniApiLib.documentService())
        self.paymentService = giniApiLib.paymentService(apiDomain: APIDomain.merchant, apiVersion: Constants.merchantVersionAPI)
    }
    
    /**
     Getting a list of the installed banking apps which support Gini Pay Connect functionality.
     
     - Parameters:
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater.
     Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success case it includes array of payment providers, which are represebt the installed on the phone apps.
     In case of failure error that there are no supported banking apps installed.
     
     */
    private func fetchInstalledBankingApps(completion: @escaping (Result<PaymentProviders, GiniMerchantError>) -> Void) {
        fetchBankingApps { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let providers):
                    self.updateBankProviders(providers: providers)
                    
                    if self.bankProviders.count > 0 {
                        completion(.success(self.bankProviders))
                    } else {
                        completion(.failure(.noInstalledApps))
                    }
                case let .failure(error):
                    
                    completion(.failure(GiniMerchantError.apiError(error)))
                }
            }
        }
    }
    
    private func updateBankProviders(providers: PaymentProviders) {
        for provider in providers {
            if let url = URL(string:provider.appSchemeIOS), UIApplication.shared.canOpenURL(url) {
                self.bankProviders.append(provider)
            }
        }
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
        paymentService.paymentProviders { result in
            switch result {
            case let .success(providers):
                self.bankProviders = providers.map { PaymentProvider(healthPaymentProvider: $0) }
                completion(.success(self.bankProviders))
            case let .failure(error):
                completion(.failure(GiniError.decorator(error)))
            }
        }
    }
    
    /**
     Sets a configuration which is used to customize the look of the Gini Merchant SDK,
     for example to change texts and colors displayed to the user.
     
     - Parameters:
        - configuration: The configuration to set.
     
     */
    public func setConfiguration(_ configuration: GiniMerchantConfiguration) {
        GiniMerchantConfiguration.shared = configuration
    }
    
    /**
     Checks if the document is payable, looks for iban extraction.

     - Parameters:
        - docId: Id of uploaded document.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. Completion block called on main thread.
        In success case it includes a boolean value and returns true if iban was extracted.
        In case of failure in case of failure error from the server side.

     */
    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniMerchantError>) -> Void) {
        documentService.fetchDocument(with: docId) { result in
            switch result {
            case let .success(createdDocument):
                self.documentService.extractions(for: createdDocument,
                                                 cancellationToken: CancellationToken()) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(extractionResult):
                            if let paymentExtractions = extractionResult.payment?.first, let iban = paymentExtractions.first(where: { $0.name == "iban" })?.value, !iban.isEmpty {
                                completion(.success(true))
                            } else if let ibanExtraction = extractionResult.extractions.first(where: { $0.name == "iban"})?.value, !ibanExtraction.isEmpty {
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
    public func pollDocument(docId: String, completion: @escaping (Result<Document, GiniMerchantError>) -> Void){
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
     Get extractions for the document.
     
     - parameter docId: Id of the uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success case it includes array of extractions.
     In case of failure in case of failure error from the server side.
     
     */
    public func getExtractions(docId: String, completion: @escaping (Result<[Extraction], GiniMerchantError>) -> Void){
        documentService.fetchDocument(with: docId) { result in
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
     Creates a payment request
     
     - Parameters:
        - paymentInfo: Model object for payment information.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success it includes the id of created payment request.
        In case of failure error from the server side.
     
     */
    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniError>) -> Void) {
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: paymentInfo.paymentProviderId, recipient: paymentInfo.recipient, iban: paymentInfo.iban, bic: "", amount: paymentInfo.amount, purpose: paymentInfo.purpose) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(requestID):
                    completion(.success(requestID))
                    self.delegate?.didCreatePaymentRequest(paymentRequestID: requestID)
                case let .failure(error):
                    completion(.failure(GiniError.decorator(error)))
                }
            }
        }
    }
    
    /**
     Opens an app of selected payment provider.
        openUrl called on main thread.
     
     - Parameters:
        - requestID: Id of the created payment request.
        - universalLink: Universal link for the selected payment provider
     */
    public func openPaymentProviderApp(requestID: String, universalLink: String, urlOpener: URLOpener = URLOpener(UIApplication.shared), completion: ((Bool) -> Void)? = nil) {
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
    public func setDocumentForReview(documentId: String, completion: @escaping (Result<[Extraction], GiniMerchantError>) -> Void) {
        documentService.fetchDocument(with: documentId) { result in
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
    public func fetchDataForReview(documentId: String, completion: @escaping (Result<DataForReview, GiniMerchantError>) -> Void) {
        documentService.fetchDocument(with: documentId) { result in
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

    public static var versionString: String {
        return GiniMerchantSDKVersion
    }
}

extension GiniMerchant {
    public enum Constants {
        public static let defaultVersionAPI = 4
        public static let merchantVersionAPI = 1
    }
}
