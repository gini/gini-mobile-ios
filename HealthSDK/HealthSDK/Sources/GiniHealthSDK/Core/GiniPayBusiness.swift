//
//  GiniPayBusiness.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 18.02.21.
//

import Foundation
import GiniPayApiLib

/**
 Delegate to inform about the current status of the Gini Pay Business SDK.
 Makes use of callback for handling payment request creation.
 
 */
public protocol GiniPayBusinessDelegate: AnyObject {
    
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
    func shouldHandleErrorInternally(error: GiniPayBusinessError) -> Bool
}
/**
 Errors thrown with GiniPayBusiness SDK.
 */
public enum GiniPayBusinessError: Error {
     /// Error thrown when there are no apps which supports Gini Pay installed.
    case noInstalledApps
     /// Error thrown when api return failure.
    case apiError(GiniError)
}
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
 Core class for GiniPayBusiness SDK.
 */
@objc public final class GiniPayBusiness: NSObject {
    /// reponsible for interaction with Gini Pay backend .
    public var giniApiLib: GiniApiLib
    /// reponsible for the whole document processing.
    public var documentService: DefaultDocumentService
    /// reponsible for the payment processing.
    public var paymentService: PaymentService
    private var bankProviders: [PaymentProvider] = []
    public weak var delegate: GiniPayBusinessDelegate?
    
    /**
     Returns a GiniPayBusiness instance
     
     - parameter giniApiLib: GiniApiLib initialized with client's credentials
     */
    public init(with giniApiLib: GiniApiLib){
        self.giniApiLib = giniApiLib
        self.documentService = giniApiLib.documentService()
        self.paymentService = giniApiLib.paymentService()
    }

    /**
     Getting a list of the installed banking apps which support Gini Pay functionality.
     
     - Parameters:
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater.
     Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success case it includes array of payment providers, which are represebt the installed on the phone apps.
     In case of failure error that there are no supported banking apps installed.
     
     */
    private func getInstalledBankingApps(completion: @escaping (Result<PaymentProviders, GiniPayBusinessError>) -> Void){
        paymentService.paymentProviders { result in
            switch result {
            case let .success(providers):
                for provider in providers {
                    DispatchQueue.main.async {
                        if let url = URL(string:provider.appSchemeIOS) {
                            if UIApplication.shared.canOpenURL(url) {
                                self.bankProviders.append(provider)
                            }
                        }
                        if self.bankProviders.count > 0 {
                            completion(.success(self.bankProviders))
                        } else {
                            completion(.failure(.noInstalledApps))
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
     Checks if there are any banking app which support Gini Pay functionality installed.
     
     - Parameters:
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. Completion block called on main thread.
        In success case it includes array of payment providers.
        In case of failure error that there are no supported banking apps installed.
     */
    public func checkIfAnyPaymentProviderAvailiable(completion: @escaping (Result<PaymentProviders, GiniPayBusinessError>) -> Void){
        self.getInstalledBankingApps(completion: completion)
    }
    
    /**
     Checks if there is any banking app which can support Gini Pay functionality installed.
     - Parameters:
        -  appSchemes: A list of [LSApplicationQueriesSchemes] added in Info.plist. Scheme format: ginipay-bank://
     - Returns: a boolean value.
     */
    public func isAnyBankingAppInstalled(appSchemes: [String]) -> Bool {
        for scheme in appSchemes {
            if let url = URL(string:scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    return true
                }
            }
        }
        return false
    }
    
    /**
     Sets a configuration which is used to customize the look of the Gini Pay Business SDK,
     for example to change texts and colors displayed to the user.
     
     - Parameters:
        - configuration: The configuration to set.
     
     */
    public func setConfiguration(_ configuration: GiniPayBusinessConfiguration) {
        GiniPayBusinessConfiguration.shared = configuration
    }
    
    /**
     Checks if the document is payable which looks for iban extraction.
     
     - Parameters:
        - docId: Id of uploaded document.
        - completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. Completion block called on main thread.
        In success case it includes a boolean value and returns true if iban was extracted.
        In case of failure in case of failure error from the server side.

     */
    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniPayBusinessError>) -> Void) {
        documentService.fetchDocument(with: docId) { result in
            switch result {
            case let .success(createdDocument):
                self.documentService.extractions(for: createdDocument,
                                                 cancellationToken: CancellationToken()) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(extractionResult):
                            if let iban = extractionResult.extractions.first(where: { $0.name == "iban" })?.value, !iban.isEmpty {
                                completion(.success(true))
                            } else {
                                completion(.success(false))
                            }
                        case .failure(let error):
                            completion(.failure(.apiError(error)))
                            break
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
        -  completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
        Completion block called on main thread.
        In success returns the polled document.
        In case of failure error from the server side.

     */
    public func pollDocument(docId: String, completion: @escaping (Result<Document, GiniPayBusinessError>) -> Void){
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
    public func getExtractions(docId: String, completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void){
            documentService.fetchDocument(with: docId) { result in
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
    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: paymentInfo.paymentProviderId, recipient: paymentInfo.recipient, iban: paymentInfo.iban, bic: "", amount: paymentInfo.amount, purpose: paymentInfo.purpose) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(requestID):
                    completion(.success(requestID))
                    self.delegate?.didCreatePaymentRequest(paymentRequestID: requestID)
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
    
    /**
     Opens an app of selected payment provider.
        openUrl called on main thread.
     
     - Parameters:
        - requestID: Id of the created payment request.
        - appScheme: App scheme for the selected payment provider
     
     */
    public func openPaymentProviderApp(requestID: String, appScheme: String) {
        let queryItems = [URLQueryItem(name: "id", value: requestID)]
        let urlString = appScheme + "://payment"
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = queryItems
        let resultUrl = urlComponents.url!
        DispatchQueue.main.async {
            UIApplication.shared.open(resultUrl, options: [:], completionHandler: nil)
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
    public func setDocumentForReview(documentId: String, completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void) {
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
    public func fetchDataForReview(documentId: String, completion: @escaping (Result<DataForReview, GiniPayBusinessError>) -> Void) {
        documentService.fetchDocument(with: documentId) { result in
            switch result {
            case let .success(document):
                self.documentService
                    .extractions(for: document,
                                 cancellationToken: CancellationToken()) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case let .success(extractionResult):
                                let fetchedData = DataForReview(document: document, extractions: extractionResult.extractions)
                                completion(.success(fetchedData))
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
}
