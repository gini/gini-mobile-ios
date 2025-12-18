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

    private func handleDocument<T>(resource: T, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {

        guard case let .document(id) = resource.method as! APIMethod else { return }

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
        default:
            fatalError("Document id not found in tests")
        }
    }

    private func handleExtractions<T>(resource: T,
                                      completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {
        guard case let .extractions(documentId) = resource.method as! APIMethod else { return }

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
        default:
            fatalError("Document id not found in tests")
        }
    }

    func data<T>(resource: T, cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                 completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        
        // mark it as intentionally unused fro sonar qube
        _ = cancellationToken
        
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .document(let id):
                handleDocument(resource: resource, completion: completion)
            case .createPaymentRequest:
                guard let paymentRequestId = MockSessionManager.paymentRequestId as? T.ResponseType else { return }
                completion(.success(paymentRequestId))

            case .paymentProvider(_):
                let providerResponse: PaymentProviderResponse? = load(fromFile: "provider")
                guard let providerResponse = providerResponse as? T.ResponseType else { return }
                completion(.success(providerResponse))

            case .paymentProviders:
                let paymentProvidersResponse: [PaymentProviderResponse]? = load(fromFile: "providers")
                guard let paymentProvidersResponse = paymentProvidersResponse as? T.ResponseType else { return }
                completion(.success(paymentProvidersResponse))

            case .extractions(let documentId):
                handleExtractions(resource: resource, completion: completion)

            default:
                let error = GiniError.unknown(response: nil, data: nil)
                completion(.failure(error))
            }
        }
    }
}

