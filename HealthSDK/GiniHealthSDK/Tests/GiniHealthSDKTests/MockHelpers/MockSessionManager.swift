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
                guard let bodyStringArray = decodeBody(from: resource.params.body) else { return }
                handleBodyStringArray(bodyStringArray, completion: completion)
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

    /// Helper function to handle the body array types
    private func handleBodyStringArray<ResponseType>(
        _ bodyStringArray: [String],
        completion: @escaping GiniHealthAPILibrary.CompletionResult<ResponseType>
    ) {
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

