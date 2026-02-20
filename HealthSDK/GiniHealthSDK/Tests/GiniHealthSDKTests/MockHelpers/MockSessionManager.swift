//
//  MockSessionManage.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
@testable import GiniHealthAPILibrary

final class MockSessionManager: SessionManagerProtocol {
    // MARK: - Public Test Constants (keep for backward compatibility)
    
    static let payableDocumentID = MockTestData.Documents.payable
    static let notPayableDocumentID = MockTestData.Documents.notPayable
    static let failurePayableDocumentID = MockTestData.Documents.failurePayable
    static let missingDocumentID = MockTestData.Documents.missing
    static let extractionsWithPaymentDocumentID = MockTestData.Documents.extractionsWithPayment
    static let paymentRequestId = MockTestData.PaymentRequests.standard
    static let doctorsNameDocumentID = MockTestData.Documents.doctorsName
    static let paymentRequestIdWithExpirationDate = MockTestData.PaymentRequests.withExpirationDate
    static let paymentRequestIdWithMissingExpirationDate = MockTestData.PaymentRequests.missingExpirationDate

    func upload<T>(resource: T,
                   data: Data,
                   cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                   completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {
        //
    }
    
    func download<T>(resource: T,
                     cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                     completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {
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
    
    func data<T>(resource: T,
                 cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                 completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {
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
                    guard let response = MockSessionManager.paymentRequestId as? T.ResponseType else {
                        let error = GiniError.unknown(response: nil, data: nil)
                        completion(.failure(error))
                        break
                    }
                    completion(.success(response))
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
                            message: "No documents to delete",
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
                    
                    // Validate document IDs using new validator
                    let validator = MockBulkDeleteValidator()
                    let validationResult = validator.validateDocuments(bodyStringArray)
                    
                    switch validationResult {
                    case .success:
                        // All documents valid - success response
                        if let emptyResponse = "" as? T.ResponseType {
                            completion(.success(emptyResponse))
                        }
                    case .failure(let errorItems):
                        // Validation failed - return custom error
                        let errorData = MockErrorGenerator.createErrorData(items: errorItems)
                        completion(.failure(.customError(response: nil, data: errorData)))
                    }
                    break
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
                
                // Validate payment request IDs using new validator
                let validator = MockBulkDeleteValidator()
                let validationResult = validator.validatePaymentRequests(bodyStringArray)
                
                switch validationResult {
                case .success:
                    // All payment requests valid - success response
                    if let emptyResponse = "" as? T.ResponseType {
                        completion(.success(emptyResponse))
                    }
                case .failure(let errorItems):
                    // Validation failed - return custom error with appropriate requestId
                    let requestId = errorItems.count > 1 
                        ? "a497-01aa-b6f0-cc17-43d3-76a8"  // Mixed errors
                        : "b608-02bb-c7g1-dd28-54e4-87b9"  // Single error type
                    let errorData = MockErrorGenerator.createErrorData(
                        items: errorItems,
                        requestId: requestId
                    )
                    completion(.failure(.customError(response: nil, data: errorData)))
                }
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

    private func processPaymentRequest<T>(_ paymentRequestId: String,
                                          completion: (Result<T, GiniError>) -> Void) {
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

    /// Helper function to handle extraction results
    private func handleExtractionResults<ResponseType>(fromFile fileName: String,
                                                       completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>) {
        let extractionResults: ExtractionsContainer? = load(fromFile: fileName)
        if let extractionResults = extractionResults as? ResponseType {
            completion(.success(extractionResults))
        }
    }
}

