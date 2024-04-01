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
    
    func upload<T>(resource: T, data: Data, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        //
    }
    
    func download<T>(resource: T, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .file(_):
                let imageData = UIImage(named: "Gini-Test-Payment-Provider", in: Bundle.module, compatibleWith: nil)?.pngData()
                completion(.success(imageData as! T.ResponseType))
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
                    let document: Document = load(fromFile: "document1", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (MockSessionManager.notPayableDocumentID, .get):
                    let document: Document = load(fromFile: "document2", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (MockSessionManager.failurePayableDocumentID, .get):
                    let document: Document = load(fromFile: "document3", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (MockSessionManager.missingDocumentID, .get):
                    completion(.failure(.notFound(response: nil, data: nil)))
                case (MockSessionManager.extractionsWithPaymentDocumentID, .get):
                    let document: Document = load(fromFile: "document4", type: "json")
                    completion(.success(document as! T.ResponseType))
                default:
                    fatalError("Document id not found in tests")
                }
            case .createPaymentRequest:
                completion(.success(MockSessionManager.paymentRequestId as! T.ResponseType))
            case .paymentProvider(_):
                let providerResponse: PaymentProviderResponse = loadProviderResponse()
                completion(.success(providerResponse as! T.ResponseType))
            case .paymentProviders:
                let paymentProvidersResponse: [PaymentProviderResponse] = loadProvidersResponse()
                completion(.success(paymentProvidersResponse as! T.ResponseType))
            case .extractions(let documentId):
                switch (documentId, resource.params.method) {
                case (MockSessionManager.payableDocumentID, .get):
                    let extractionResults: ExtractionsContainer = loadExtractionResults(fileName: "extractionResultWithIBAN", type: "json")
                    completion(.success(extractionResults as! T.ResponseType))
                case (MockSessionManager.notPayableDocumentID, .get):
                    let extractionResults: ExtractionsContainer = loadExtractionResults(fileName: "extractionResultWithoutIBAN", type: "json")
                    completion(.success(extractionResults as! T.ResponseType))
                case (MockSessionManager.failurePayableDocumentID, .get):
                    completion(.failure(.noResponse))
                case (MockSessionManager.extractionsWithPaymentDocumentID, .get):
                    let extractionResults: ExtractionsContainer = loadExtractionResults(fileName: "extractionsWithPayment", type: "json")
                    completion(.success(extractionResults as! T.ResponseType))
                default:
                    fatalError("Document id not found in tests")
                }
            default:
                let error = GiniError.unknown(response: nil, data: nil)
                completion(.failure(error))
            }
        }
    }
}

