//
//  MockSessionManage.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
@testable import GiniHealthAPILibrary

final class MockSessionManager: SessionManagerProtocol {
    static let payableDocumentID = "626626a0-749f-11e2-bfd6-000000000001"
    static let notPayableDocumentID = "626626a0-749f-11e2-bfd6-000000000002"
    static let failurePayableDocumentID = "626626a0-749f-11e2-bfd6-000000000003"
    static let missingDocumentID = "626626a0-749f-11e2-bfd6-000000000000"
    static let extractionsWithPaymentDocumentID = "626626a0-749f-11e2-bfd6-000000000004"
    static let paymentRequestId = "b09ef70a-490f-11eb-952e-9bc6f4646c57"
    static let doctorsNameDocumentID = "626626a0-749f-11e2-bfd6-000000000005"
    static let paymentRequestIdWithExpirationDate = "1"
    static let paymentRequestIdWithMissingExpirationDate = "2"

    func upload<T>(resource: T,
                   data: Data,
                   cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                   completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func download<T>(resource: T,
                     cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                     completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {

        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .file(_):
                let imageData = UIImage(named: "Gini-Test-Payment-Provider", in: Bundle.module, compatibleWith: nil)?.pngData()
                if let imageData = imageData as? T.ResponseType {
                    completion(.success(imageData))
                }
            default:
                break
            }
        }
    }
    
    func logIn(completion: @escaping (Result<GiniHealthAPILibrary.Token, GiniHealthAPILibrary.GiniError>) -> Void) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func logOut() {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func data<T>(resource: T,
                 cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                 completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {

        guard let apiMethod = resource.method as? APIMethod else {
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }

        handleAPIMethod(apiMethod, resource: resource, completion: completion)
    }

    // MARK: - API Method Handling

    private func handleAPIMethod<T>(_ apiMethod: APIMethod,
                                    resource: T,
                                    completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        switch apiMethod {
            case .document(let id):
                handleDocumentRequest(id: id, method: resource.params.method, completion: completion)
            case .createPaymentRequest:
                handleCreatePaymentRequest(completion: completion)
            case .paymentProvider:
                handlePaymentProvider(completion: completion)
            case .paymentProviders:
                handlePaymentProviders(completion: completion)
            case .extractions(let documentId):
                handleExtractions(documentId: documentId, method: resource.params.method, completion: completion)
            case .configurations:
                handleConfigurations(completion: completion)
            case .paymentRequest(let paymentRequestId):
                handlePaymentRequest(paymentRequestId: paymentRequestId, method: resource.params.method, completion: completion)
            case .documents:
                handleDocuments(body: resource.params.body, completion: completion)
            case .payment:
                handlePayment(completion: completion)
            default:
                completion(.failure(.unknown(response: nil, data: nil)))
        }
    }

    // MARK: - Document Handling

    private func handleDocumentRequest<T: Decodable>(id: String,
                                                     method: HTTPMethod,
                                                     completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        guard method == .get else {
            fatalError("Unsupported method for document request")
        }

        let fileName: String
        switch id {
            case MockSessionManager.payableDocumentID:
                fileName = "document1"
            case MockSessionManager.notPayableDocumentID:
                fileName = "document2"
            case MockSessionManager.failurePayableDocumentID:
                fileName = "document3"
            case MockSessionManager.extractionsWithPaymentDocumentID:
                fileName = "document4"
            case MockSessionManager.doctorsNameDocumentID:
                fileName = "document5"
            case MockSessionManager.missingDocumentID:
                completion(.failure(.notFound(response: nil, data: nil)))
                return
            default:
                fatalError("Document id not found in tests")
        }

        loadAndComplete(fromFile: fileName, type: "json", completion: completion)
    }

    // MARK: - Extraction Handling

    private func handleExtractions<T>(documentId: String,
                                      method: HTTPMethod,
                                      completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        guard method == .get else {
            fatalError("Unsupported method for extractions request")
        }

        switch documentId {
            case MockSessionManager.payableDocumentID:
                handleExtractionResults(fromFile: "extractionResultWithIBAN", completion: completion)
            case MockSessionManager.notPayableDocumentID:
                handleExtractionResults(fromFile: "extractionResultWithoutIBAN", completion: completion)
            case MockSessionManager.failurePayableDocumentID:
                completion(.failure(.noResponse))
            case MockSessionManager.extractionsWithPaymentDocumentID:
                handleExtractionResults(fromFile: "extractionsWithPayment", completion: completion)
            case MockSessionManager.doctorsNameDocumentID:
                handleExtractionResults(fromFile: "test_doctorsname", completion: completion)
            default:
                fatalError("Document id not found in tests")
        }
    }

    // MARK: - Payment Request Handling

    private func handlePaymentRequest<T>(paymentRequestId: String,
                                         method: HTTPMethod,
                                         completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        if method == .delete {
            if let response = MockSessionManager.paymentRequestId as? T {
                completion(.success(response))
            }
        } else {
            processPaymentRequest(paymentRequestId, completion: completion)
        }
    }

    // MARK: - Simple Resource Handlers

    private func handleCreatePaymentRequest<T: Decodable>(completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        if let paymentRequestId = MockSessionManager.paymentRequestId as? T {
            completion(.success(paymentRequestId))
        }
    }

    private func handlePaymentProvider<T: Decodable>(completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        loadAndComplete(fromFile: "provider", completion: completion)
    }

    private func handlePaymentProviders<T: Decodable>(completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        loadAndComplete(fromFile: "providers", completion: completion)
    }

    private func handleConfigurations<T: Decodable>(completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        loadAndComplete(fromFile: "clientConfiguration", completion: completion)
    }

    private func handlePayment<T: Decodable>(completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        loadAndComplete(fromFile: "payment", completion: completion)
    }

    private func handleDocuments<T: Decodable>(body: Data?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        guard let bodyStringArray = decodeBody(from: body) else { return }
        handleBodyStringArray(bodyStringArray, completion: completion)
    }

    // MARK: - Helper Methods

    private func loadAndComplete<T: Decodable>(fromFile fileName: String,
                                               type: String = "json",
                                               completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        let resource: T? = load(fromFile: fileName, type: type)
        if let resource = resource {
            completion(.success(resource))
        }
    }

    private func processPaymentRequest<T>(_ paymentRequestId: String, completion: (Result<T, GiniError>) -> Void) {
        let fileName: String
        switch paymentRequestId {
            case MockSessionManager.paymentRequestIdWithMissingExpirationDate:
                fileName = "paymentRequestWithMissingExpirationDate"
            case MockSessionManager.paymentRequestIdWithExpirationDate:
                fileName = "paymentRequestWithExpirationDate"
            default:
                fatalError("Payment Request Id not found in tests")
        }

        let paymentRequest: PaymentRequest? = load(fromFile: fileName)
        if let paymentRequest = paymentRequest as? T {
            completion(.success(paymentRequest))
        }
    }


    /// Helper function to handle the body array types
    private func handleBodyStringArray<ResponseType>(_ bodyStringArray: [String],
                                                     completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>) {
        switch bodyStringArray {
        case [""]:
            if let emptyResponse = "" as? ResponseType {
                completion(.success(emptyResponse))
            }
        case ["unauthorizedDocuments"]:
            handleDeleteDocumentsError(fromFile: "unauthorizedDocumentsError", completion: completion)
        case ["notFoundDocuments"]:
            handleDeleteDocumentsError(fromFile: "notFoundDocumentsError", completion: completion)
        case ["missingCompositeDocuments"]:
            handleDeleteDocumentsError(fromFile: "missingCompositeDocumentsError", completion: completion)
        default:
            completion(.failure(GiniError.unknown(response: nil, data: nil)))
        }
    }

    /// Helper function to load and encode errors
    private func handleDeleteDocumentsError<ResponseType>(fromFile fileName: String,
                                                          completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>) {
        guard let extractionResults: GiniCustomError = load(fromFile: fileName),
              let jsonData = try? JSONEncoder().encode(extractionResults) else {
            return
        }

        let error = GiniError.customError(response: nil, data: jsonData)
        completion(.failure(error))
    }

    /// Helper function to handle extraction results
    private func handleExtractionResults<ResponseType>(fromFile fileName: String,
                                                       completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>) {
        let extractionResults: ExtractionsContainer? = load(fromFile: fileName)
        if let extractionResults = extractionResults as? ResponseType {
            completion(.success(extractionResults))
        }
    }
}

