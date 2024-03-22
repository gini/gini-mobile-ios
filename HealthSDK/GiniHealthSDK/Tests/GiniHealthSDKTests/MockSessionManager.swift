//
//  MockSessionManage.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
@testable import GiniHealthAPILibrary

final class MockSessionManager: SessionManagerProtocol {
    static let payableDocumentID = "626626a0-749f-11e2-bfd6-000000000000"
    static let notPayableDocumentID = "626626a0-749f-11e2-bfd6-000000000001"
    static let failurePayableDocumentID = "626626a0-749f-11e2-bfd6-000000000002"
    
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
//                case (SessionManagerMock.v3DocumentId, .delete):
//                    documents.removeAll(where: { $0.id == id })
//                    completion(.success("Deleted" as! T.ResponseType))
//                case (SessionManagerMock.partialDocumentId, .get):
//                    let document: Document = load(fromFile: "partialDocument", type: "json")
//                    completion(.success(document as! T.ResponseType))
//                case (SessionManagerMock.partialDocumentId, .delete):
//                    documents.removeAll(where: { $0.id == id })
//                    completion(.success("Deleted" as! T.ResponseType))
//                case (SessionManagerMock.compositeDocumentId, .get):
//                    let document: Document = load(fromFile: "compositeDocument", type: "json")
//                    completion(.success(document as! T.ResponseType))
//                case (SessionManagerMock.compositeDocumentId, .delete):
//                    documents.removeAll(where: { $0.id == id })
//                    completion(.success("Deleted" as! T.ResponseType))
                default:
                    fatalError("Document id not found in tests")
                }
//            case .createDocument(_, _, _, _):
//                completion(.success(SessionManagerMock.compositeDocumentId as! T.ResponseType))
//            case .createPaymentRequest:
//                completion(.success(SessionManagerMock.paymentRequestId as! T.ResponseType))
            case .paymentProvider(_):
                let providerResponse: PaymentProviderResponse = loadProviderResponse()
                completion(.success(providerResponse as! T.ResponseType))
            case .paymentProviders:
                let paymentProvidersResponse: [PaymentProviderResponse] = loadProvidersResponse()
                completion(.success(paymentProvidersResponse as! T.ResponseType))
//            case .paymentRequest(_):
//                let paymentRequest: PaymentRequest = loadPaymentRequest()
//                completion(.success(paymentRequest as! T.ResponseType))
//            case .feedback(_):
//                extractionFeedbackBody = resource.request.httpBody ?? nil
//                completion(.success("Feedback was sent" as! T.ResponseType))
            case .extractions(let documentId):
                switch (documentId, resource.params.method) {
                case (MockSessionManager.payableDocumentID, .get):
                    let extractionResults: ExtractionsContainer = loadExtractionResults(fileName: "result_Gini_invoice_example", type: "json")
                    completion(.success(extractionResults as! T.ResponseType))
                case (MockSessionManager.notPayableDocumentID, .get):
                    let extractionResults: ExtractionsContainer = loadExtractionResults(fileName: "extractionResultWithoutIBAN", type: "json")
                    completion(.success(extractionResults as! T.ResponseType))
                case (MockSessionManager.failurePayableDocumentID, .get):
                    completion(.failure(.noResponse))
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

