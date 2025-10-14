//
//  SessionManagerMock.swift
//  GiniBankAPI-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/26/19.
//

import Foundation
import XCTest
@testable import GiniBankAPILibrary

final class SessionManagerMock: SessionManagerProtocol {
    
    static let v1DocumentId = "626626a0-749f-11e2-bfd6-000000000000"
    static let partialDocumentId = "726626a0-749f-11e2-bfd6-000000000000"
    static let compositeDocumentId = "826626a0-749f-11e2-bfd6-000000000000"
    static let paymentProviderId = "b09ef70a-490f-11eb-952e-9bc6f4646c57"
    static let paymentRequestId = "118edf41-102a-4b40-8753-df2f0634cb86"
    static let paymentRequesterUri = "ginipay-test://paymentRequester"

    static let paymentRequestURL = "https://pay-api.gini.net/paymentRequests/118edf41-102a-4b40-8753-df2f0634cb86/payment"
    static let paymentID = "b4bd3e80-7bd1-11e4-95ab-000000000000"
    var documents: [Document] = []
    var paymentRequests: [PaymentRequest] = []
    var extractionFeedbackBody: Data?
    var logErrorEventBody: Data?


    init(keyStore: KeyStore = KeychainStore(),
         urlSession: URLSession = URLSession(configuration: .default)) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func initializeWithV1MockedDocuments() {
        documents = [
            load(fromFile: "document", type: "json")
        ]
    }
    
    func initializeWithPaymentRequests() {
        paymentRequests = loadPaymentRequests()
    }
    
    func initializeWithV2MockedDocuments() {
        documents = [
            load(fromFile: "partialDocument", type: "json"),
            load(fromFile: "compositeDocument", type: "json")
        ]
    }
    
    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func logOut() {
        // This method will remain empty; mock implementation does not perform login
    }
    
    //swiftlint:disable all
    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {                
            case .document(let id):
                handleDocument(id: id, method: resource.params.method, completion: completion)
                
            case .createDocument(_, _, _, _):
                completion(.success(SessionManagerMock.compositeDocumentId as! T.ResponseType))
            case .paymentRequest(_):
                let paymentRequest: PaymentRequest = loadPaymentRequest()
                completion(.success(paymentRequest as! T.ResponseType))
            case .resolvePaymentRequest(_):
                let paymentRequest: ResolvedPaymentRequest = loadResolvedPaymentRequest()
                completion(.success(paymentRequest as! T.ResponseType))
            case .payment(_):
                let payment: Payment = loadPayment()
                completion(.success(payment as! T.ResponseType))
            case .feedback(_):
                extractionFeedbackBody = resource.request?.httpBody ?? nil
                completion(.success("Feedback was sent" as! T.ResponseType))
            case .logErrorEvent:
                logErrorEventBody = resource.request?.httpBody ?? nil
                completion(.success("Logged" as! T.ResponseType))
            default: break
            }
        }
    }
    
    private func handleDocument<T>(id: String, method: HTTPMethod,
                                   completion: @escaping CompletionResult<T>) {
        
        switch (id, method) {
        case (SessionManagerMock.v1DocumentId, .get):
            let document: Document = load(fromFile: "document", type: "json")
            completion(.success(document as! T))
            
        case (SessionManagerMock.v1DocumentId, .delete):
            documents.removeAll(where: { $0.id == id })
            completion(.success("Deleted" as! T))
            
        case (SessionManagerMock.partialDocumentId, .get):
            let document: Document = load(fromFile: "partialDocument", type: "json")
            completion(.success(document as! T))
            
        case (SessionManagerMock.partialDocumentId, .delete):
            documents.removeAll(where: { $0.id == id })
            completion(.success("Deleted" as! T))
            
        case (SessionManagerMock.compositeDocumentId, .get):
            let document: Document = load(fromFile: "compositeDocument", type: "json")
            completion(.success(document as! T))
            
        case (SessionManagerMock.compositeDocumentId, .delete):
            documents.removeAll(where: { $0.id == id })
            completion(.success("Deleted" as! T))
            
        default:
            fatalError("Document id not found in tests")
        }
    }

    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .createDocument(_, _, _, let documentType):
                switch documentType {
                case .none:
                    completion(.success(SessionManagerMock.v1DocumentId as! T.ResponseType))
                case .some:
                    completion(.success(SessionManagerMock.partialDocumentId as! T.ResponseType))
                }
            default: break
                
            }
        }
    }
}
