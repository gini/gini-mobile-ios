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
                    let extractionResults: ExtractionsContainer? = load(fromFile: "extractionResultWithIBAN")
                    if let extractionResults = extractionResults as? T.ResponseType {
                        completion(.success(extractionResults))
                    }
                case (MockSessionManager.notPayableDocumentID, .get):
                    let extractionResults: ExtractionsContainer? = load(fromFile: "extractionResultWithoutIBAN")
                    if let extractionResults = extractionResults as? T.ResponseType {
                        completion(.success(extractionResults))
                    }
                case (MockSessionManager.failurePayableDocumentID, .get):
                    completion(.failure(.noResponse))
                case (MockSessionManager.extractionsWithPaymentDocumentID, .get):
                    let extractionResults: ExtractionsContainer? = load(fromFile: "extractionsWithPayment")
                    if let extractionResults = extractionResults as? T.ResponseType {
                        completion(.success(extractionResults))
                    }
                case (MockSessionManager.doctorsNameDocumentID, .get):
                    let extractionResults: ExtractionsContainer? = load(fromFile: "test_doctorsname")
                    if let extractionResults = extractionResults as? T.ResponseType {
                        completion(.success(extractionResults))
                    }
                default:
                    fatalError("Document id not found in tests")
                }
            case .configurations:
                let clientConfiguration: ClientConfiguration? = load(fromFile: "clientConfiguration")
                if let clientConfiguration = clientConfiguration as? T.ResponseType {
                    completion(.success(clientConfiguration))
                }
            case .documents(_, _):
                guard resource.params.method == .delete,
                      let body = resource.params.body,
                      let bodyStringArray = try? JSONDecoder().decode([String].self, from: body) else {
                    return
                }

                switch bodyStringArray {
                case [""]:
                    if let emptyResponse = "" as? T.ResponseType {
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
            default:
                let error = GiniError.unknown(response: nil, data: nil)
                completion(.failure(error))
            }
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
}

