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

    enum BulkDocsDeletionParams {
        static let notFoundDocuments = ["3db07630-8f16-11ec-bd63-31f9d04e200e", "0db26fec-4a7f-4376-b5d5-5155adf8adca"]
        static let unauthorizedDocuments = ["3db07630-8f16-11ec-bd63-31f9d04e200e", "0db26fec-4a7f-4376-b5d5-5155adf8adca"]
        static let missingCompositeItems = ["3db07630-8f16-11ec-bd63-31f9d04e200e", "0db26fec-4a7f-4376-b5d5-5155adf8adca"]
        static let mixedNotFoundAndNotUnAuthorizedDocuments = ["3db07630-8f16-11ec-bd63-31f9d04e200e", "0db26fec-4a7f-4376-b5d5-5155adf8adca"]
        static let mixedNotFoundAndMissingCompositeItems = ["3db07630-8f16-11ec-bd63-31f9d04e200e", "0db26fec-4a7f-4376-b5d5-5155adf8adca"]
        static let mixedNotFoundAndUnAuthorizedAndMissingCompositeItems = ["3db07630-8f16-11ec-bd63-31f9d04e200e", "0db26fec-4a7f-4376-b5d5-5155adf8adca"]
    }

    enum BulkDocsDeleteErrorType {
        case notFoundDocuments
        case unauthorizedDocuments
        case missingCompositeItems
        case mixedNotFoundAndNotUnAuthorizedDocuments
        case mixedNotFoundAndMissingCompositeItems
        case mixedNotFoundAndUnAuthorizedAndMissingCompositeItems
    }
    
    enum BulkPaymentRequestsDeletionParams {
        static let notFoundPaymentRequests = ["bfb74b1b-567e-471e-ac5d-9e4494d0d049"]
        static let unauthorizedPaymentRequests = ["8d5h7630-8f16-11ec-bd63-31f9d04e200e", "92de6fec-4a7f-4376-b5d5-5155adf8adca"]
        static let mixedPaymentRequests = ["8d5h7630-8f16-11ec-bd63-31f9d04e200e", "92de6fec-4a7f-4376-b5d5-5155adf8adca", "bfb74b1b-567e-471e-ac5d-9e4494d0d049"]
    }
    
    enum BulkPaymentRequestsDeleteErrorType {
        case notFoundPaymentRequests
        case unauthorizedPaymentRequests
        case mixedPaymentRequests
    }

    func upload<T>(resource: T, data: Data, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        //
    }
    
    func download<T>(resource: T, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
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
        //
    }
    
    func logOut() {
        //
    }
    
    func data<T>(resource: T, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .document(let id):
                switch (id, resource.params.method) {
                case (MockSessionManager.payableDocumentID, .get):
                    let document: Document? = load(fromFile: "document1", type: "json")
                    if let document = document as? T.ResponseType {
                        completion(.success(document))
                    }
                case (MockSessionManager.notPayableDocumentID, .get):
                    let document: Document? = load(fromFile: "document2", type: "json")
                    if let document = document as? T.ResponseType {
                        completion(.success(document))
                    }
                case (MockSessionManager.failurePayableDocumentID, .get):
                    let document: Document? = load(fromFile: "document3", type: "json")
                    if let document = document as? T.ResponseType {
                        completion(.success(document))
                    }
                case (MockSessionManager.missingDocumentID, .get):
                    completion(.failure(.notFound(response: nil, data: nil)))
                case (MockSessionManager.extractionsWithPaymentDocumentID, .get):
                    let document: Document? = load(fromFile: "document4", type: "json")
                    if let document = document as? T.ResponseType {
                        completion(.success(document))
                    }
                case (MockSessionManager.doctorsNameDocumentID, .get):
                    let document: Document? = load(fromFile: "document5", type: "json")
                    if let document = document as? T.ResponseType {
                        completion(.success(document))
                    }
                default:
                    fatalError("Document id not found in tests")
                }
            case .createPaymentRequest:
                if let paymentRequestId = MockSessionManager.paymentRequestId as? T.ResponseType {
                    completion(.success(paymentRequestId))
                }
            case .paymentProvider(_):
                let providerResponse: PaymentProviderResponse? = load(fromFile: "provider")
                if let providerResponse = providerResponse as? T.ResponseType {
                    completion(.success(providerResponse))
                }
            case .paymentProviders:
                let paymentProvidersResponse: [PaymentProviderResponse]? = load(fromFile: "providers")
                if let paymentProvidersResponse = paymentProvidersResponse as? T.ResponseType {
                    completion(.success(paymentProvidersResponse))
                }
            case .extractions(let documentId):
                switch (documentId, resource.params.method) {
                case (MockSessionManager.payableDocumentID, .get):
                    handleExtractionResults(fromFile: "extractionResultWithIBAN", completion: completion)
                case (MockSessionManager.notPayableDocumentID, .get):
                    handleExtractionResults(fromFile: "extractionResultWithoutIBAN", completion: completion)
                case (MockSessionManager.failurePayableDocumentID, .get):
                    completion(.failure(.noResponse))
                case (MockSessionManager.extractionsWithPaymentDocumentID, .get):
                    handleExtractionResults(fromFile: "extractionsWithPayment", completion: completion)
                case (MockSessionManager.doctorsNameDocumentID, .get):
                    handleExtractionResults(fromFile: "test_doctorsname", completion: completion)
                default:
                    fatalError("Document id not found in tests")
                }
            case .configurations:
                let clientConfiguration: ClientConfiguration? = load(fromFile: "clientConfiguration")
                if let clientConfiguration = clientConfiguration as? T.ResponseType {
                    completion(.success(clientConfiguration))
                }
            case .paymentRequest(let paymentRequestId):
                if resource.params.method == .delete {
                    completion(.success(MockSessionManager.paymentRequestId as! T.ResponseType))
                } else {
                    processPaymentRequest(paymentRequestId, completion: completion)
                }
                case .documents(_, _):
                    // Decode the body as an array of IDs
                    guard let bodyStringArray = decodeBody(from: resource.params.body) else {
                        let error = GiniError.unknown(response: nil, data: nil)
                        completion(.failure(error))
                        break
                    }

                    // Simulate validation rules:
                    // 1) Array size validation fails (empty array) -> 400 with message
                    if bodyStringArray.isEmpty {
                        // Build a custom error matching: items: [], message: "No payment requests to delete"
                        let errorData = GiniCustomError(
                            message: "No payment requests to delete",
                            items: [],
                            requestId: "b66a-2a15-8935-dbe4-f239-8457"
                        )
                        let jsonData = try? JSONEncoder().encode(errorData)
                        let customError = GiniError.customError(
                            response: nil,
                            data: jsonData
                        )
                        // Return as a custom error
                        completion(.failure(customError))
                        break
                    }

                    // Special-case: a single empty string [""] should be treated as success

                    if bodyStringArray == [""] {
                        if let emptyResponse = "" as? T.ResponseType {
                            completion(.success(emptyResponse))
                            break
                        }
                    }
                    // 2) Per-ID validation fails when known invalid IDs are present
                    // Define some IDs to trigger different validation error codes
                    var errorType = BulkDocsDeleteErrorType.notFoundDocuments
                    let notFoundErrorItem = ErrorItem(code: "2014", object: MockSessionManager.BulkDocsDeletionParams.notFoundDocuments)
                    let missingCompositeItemsErrorItem = ErrorItem(code: "2015", object: MockSessionManager.BulkDocsDeletionParams.missingCompositeItems)
                    let unauthorizedErrorItem = ErrorItem(code: "2013", object: MockSessionManager.BulkDocsDeletionParams.unauthorizedDocuments)
                    var items: [ErrorItem] = []
                    if bodyStringArray.contains(
                        where: { MockSessionManager.BulkDocsDeletionParams.notFoundDocuments.contains(
                            $0
                        )
                        }) {
                        items.append(notFoundErrorItem)
                        errorType = .notFoundDocuments
                    } else if bodyStringArray.contains(
                        where: { MockSessionManager.BulkDocsDeletionParams.missingCompositeItems.contains(
                            $0
                        )
                        }) {
                        items.append(missingCompositeItemsErrorItem)
                        errorType = .missingCompositeItems
                    } else if bodyStringArray.contains(
                        where: { MockSessionManager.BulkDocsDeletionParams.unauthorizedDocuments.contains(
                            $0
                        )
                        }) {
                        items.append(unauthorizedErrorItem)
                        errorType = .unauthorizedDocuments
                    } else if bodyStringArray.contains(
                        where: { MockSessionManager.BulkDocsDeletionParams.mixedNotFoundAndMissingCompositeItems.contains(
                            $0
                        )
                        }) {
                        items.append(notFoundErrorItem)
                        items.append(missingCompositeItemsErrorItem)
                        errorType = .mixedNotFoundAndMissingCompositeItems
                    } else if bodyStringArray.contains(
                        where: { MockSessionManager.BulkDocsDeletionParams.mixedNotFoundAndNotUnAuthorizedDocuments.contains(
                            $0
                        )
                        }) {
                        items.append(notFoundErrorItem)
                        items.append(unauthorizedErrorItem)

                        errorType = .mixedNotFoundAndNotUnAuthorizedDocuments
                    } else if bodyStringArray.contains(
                        where: { MockSessionManager.BulkDocsDeletionParams.mixedNotFoundAndUnAuthorizedAndMissingCompositeItems.contains(
                            $0
                        )
                        }) {
                        items.append(notFoundErrorItem)
                        items.append(unauthorizedErrorItem)
                        items.append(missingCompositeItemsErrorItem)

                        errorType = .mixedNotFoundAndUnAuthorizedAndMissingCompositeItems
                    }

                    if !items.isEmpty {

                        handleBulkDeleteDocumentsError(
                            errorType: errorType,
                            completion: completion
                        )
                        break
                    }
            case .paymentRequests(_, _):
                // Handle bulk payment request deletion
                guard let bodyStringArray = decodeBody(from: resource.params.body) else {
                    let error = GiniError.unknown(response: nil, data: nil)
                    completion(.failure(error))
                    break
                }
                
                // Check for empty array
                if bodyStringArray.isEmpty {
                    let errorData = GiniCustomError(
                        message: "No payment requests to delete",
                        items: [],
                        requestId: "c77b-3b26-9046-ecf5-g350-9568"
                    )
                    if let jsonData = try? JSONEncoder().encode(errorData) {
                        let error = GiniError.customError(response: nil, data: jsonData)
                        completion(.failure(error))
                    }
                    break
                }
                
                // Check for specific test IDs that should trigger errors
                if bodyStringArray == [""] {
                    if let emptyResponse = "" as? T.ResponseType {
                        completion(.success(emptyResponse))
                        break
                    }
                }
                
                var errorType = BulkPaymentRequestsDeleteErrorType.notFoundPaymentRequests
                let hasUnauthorized = bodyStringArray.contains(where: { BulkPaymentRequestsDeletionParams.unauthorizedPaymentRequests.contains($0) })
                let hasNotFound = bodyStringArray.contains(where: { BulkPaymentRequestsDeletionParams.notFoundPaymentRequests.contains($0) })
                
                if hasUnauthorized && hasNotFound {
                    errorType = .mixedPaymentRequests
                } else if hasUnauthorized {
                    errorType = .unauthorizedPaymentRequests
                } else if hasNotFound {
                    errorType = .notFoundPaymentRequests
                }
                
                handleBulkDeletePaymentRequestsError(errorType: errorType, completion: completion)
            case .payment(_):
                let paymentResponse: Payment? = load(fromFile: "payment")
                if let paymentResponse = paymentResponse as? T.ResponseType {
                    completion(.success(paymentResponse))
                }
            default:
                let error = GiniError.unknown(response: nil, data: nil)
                completion(.failure(error))
            }
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

    /// Helper function to decode body
    private func decodeBody(from body: Data?) -> [String]? {
        guard let body = body else { return nil }
        return try? JSONDecoder().decode([String].self, from: body)
    }

    private func handleBulkDeleteDocumentsError<ResponseType>(errorType: BulkDocsDeleteErrorType,
                                                               completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>
    ) {
        let fileName: String
        switch errorType {
            case .notFoundDocuments:
                fileName = "bulkDocsDeletionErrorNotFound"
            case .unauthorizedDocuments:
                fileName = "bulkDocsDeletionErrorNotAuthorized"
            case .missingCompositeItems:
                fileName = "bulkDocsDeletionErrorCompositeMissing"
            case .mixedNotFoundAndNotUnAuthorizedDocuments:
                fileName = "batchDocumentDeletionFailureUnauthorizedDocuments"
            case .mixedNotFoundAndMissingCompositeItems:
                fileName = "batchDocumentDeletionFailureMissingCompositeItems"
            case .mixedNotFoundAndUnAuthorizedAndMissingCompositeItems:
                fileName = "batchDocumentDeletionFailureUnauthorizedDocuments"
        }
        handleDeleteDocumentsError(fromFile: fileName, completion: completion)
    }
    
    private func handleBulkDeletePaymentRequestsError<ResponseType>(errorType: BulkPaymentRequestsDeleteErrorType,
                                                                       completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>
    ) {
        let fileName: String
        switch errorType {
            case .notFoundPaymentRequests:
                fileName = "bulkPaymentRequestsDeletionErrorNotFound"
            case .unauthorizedPaymentRequests:
                fileName = "bulkPaymentRequestsDeletionErrorUnauthorized"
            case .mixedPaymentRequests:
                fileName = "bulkPaymentRequestsDeletionErrorMixed"
        }
        handleDeleteDocumentsError(fromFile: fileName, completion: completion)
    }

    /// Helper function to load and encode errors
    private func handleDeleteDocumentsError<ResponseType>(
        fromFile fileName: String,
        completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>
    ) {
        guard let extractionResults: GiniCustomError = load(fromFile: fileName),
              let jsonData = try? JSONEncoder().encode(extractionResults) else {
            return
        }

        let error = GiniError.customError(response: nil, data: jsonData)
        completion(.failure(error))
    }

    /// Helper function to handle extraction results
    private func handleExtractionResults<ResponseType>(
        fromFile fileName: String,
        completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>
    ) {
        let extractionResults: ExtractionsContainer? = load(fromFile: fileName)
        if let extractionResults = extractionResults as? ResponseType {
            completion(.success(extractionResults))
        }
    }
}

