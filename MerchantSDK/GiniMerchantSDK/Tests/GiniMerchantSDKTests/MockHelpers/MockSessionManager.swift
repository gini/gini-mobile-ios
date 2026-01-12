//
//  MockSessionManager.swift
//  GiniMerchantSDK
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
    
    func upload<T>(resource: T,
                   data: Data, cancellationToken: GiniHealthAPILibrary.CancellationToken?,
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

        switch apiMethod {
            case .document(let id):
                handleDocumentRequest(id: id, method: resource.params.method, completion: completion)
            case .createPaymentRequest:
                handleCreatePaymentRequest(completion: completion)
            case .paymentProvider:
                loadAndComplete(fromFile: "provider", completion: completion)
            case .paymentProviders:
                loadAndComplete(fromFile: "providers", completion: completion)
            case .extractions(let documentId):
                handleExtractionsRequest(documentId: documentId, method: resource.params.method, completion: completion)
            default:
                completion(.failure(.unknown(response: nil, data: nil)))
        }
    }

    // MARK: - Helper Methods

    private func handleDocumentRequest<T:Decodable>(id: String,
                                                    method: HTTPMethod,
                                                    completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        
        switch (id, method) {
            case (MockSessionManager.payableDocumentID, .get):
                loadAndComplete(fromFile: "document1", type: "json", completion: completion)
            case (MockSessionManager.notPayableDocumentID, .get):
                loadAndComplete(fromFile: "document2", type: "json", completion: completion)
            case (MockSessionManager.failurePayableDocumentID, .get):
                loadAndComplete(fromFile: "document3", type: "json", completion: completion)
            case (MockSessionManager.missingDocumentID, .get):
                completion(.failure(.notFound(response: nil, data: nil)))
            case (MockSessionManager.extractionsWithPaymentDocumentID, .get):
                loadAndComplete(fromFile: "document4", type: "json", completion: completion)
            default:
                fatalError("Document id not found in tests")
        }
    }

    private func handleExtractionsRequest<T: Decodable>(documentId: String,
                                                        method: HTTPMethod,
                                                        completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {

        switch (documentId, method) {
            case (MockSessionManager.payableDocumentID, .get):
                loadAndComplete(fromFile: "extractionResultWithIBAN", completion: completion)
            case (MockSessionManager.notPayableDocumentID, .get):
                loadAndComplete(fromFile: "extractionResultWithoutIBAN", completion: completion)
            case (MockSessionManager.failurePayableDocumentID, .get):
                completion(.failure(.noResponse))
            case (MockSessionManager.extractionsWithPaymentDocumentID, .get):
                loadAndComplete(fromFile: "extractionsWithPayment", completion: completion)
            default:
                fatalError("Document id not found in tests")
        }
    }

    private func handleCreatePaymentRequest<T: Decodable>(completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        if let paymentRequestId = MockSessionManager.paymentRequestId as? T {
            completion(.success(paymentRequestId))
        }
    }

    private func loadAndComplete<T: Decodable>(fromFile fileName: String,
                                              type: String = "json",
                                              completion: @escaping GiniHealthAPILibrary.CompletionResult<T>) {
        let loadedData: T? = load(fromFile: fileName, type: type)
        if let data = loadedData {
            completion(.success(data))
        }
    }
}

