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
        documents = [load(fromFile: "document", type: "json")]
    }
    
    func initializeWithPaymentRequests() {
        paymentRequests = loadPaymentRequests()
    }
    
    func initializeWithV2MockedDocuments() {
        documents = [load(fromFile: "partialDocument", type: "json"),
                     load(fromFile: "compositeDocument", type: "json")]
    }
    
    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func logOut() {
        // This method will remain empty; mock implementation does not perform login
    }

    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard let apiMethod = resource.method as? APIMethod else { return }

        switch apiMethod {

            case .document(let id):
                handleDocument(id: id,
                               method: resource.params.method,
                               completion: completion)

            case .createDocument:
                deliver(SessionManagerMock.compositeDocumentId, to: completion)

            case .paymentRequest:
                deliver(loadPaymentRequest(), to: completion)

            case .resolvePaymentRequest:
                deliver(loadResolvedPaymentRequest(), to: completion)

            case .payment:
                deliver(loadPayment(), to: completion)

            case .feedback:
                extractionFeedbackBody = resource.request?.httpBody
                deliver("Feedback was sent", to: completion)

            case .logErrorEvent:
                logErrorEventBody = resource.request?.httpBody
                deliver("Logged", to: completion)

            default:
                break
        }
    }

    // MARK: - Document branch

    private func handleDocument<ResponseType>(id: String,
                                              method: HTTPMethod,
                                              completion: @escaping (Result<ResponseType, GiniError>) -> Void) {
        let fileById: [String: String] = [
            SessionManagerMock.v1DocumentId: "document",
            SessionManagerMock.partialDocumentId: "partialDocument",
            SessionManagerMock.compositeDocumentId: "compositeDocument"
        ]

        switch method {
        case .get:
            guard let filename = fileById[id] else {
                fatalError("Document id not found in tests")
            }
            let document: Document = load(fromFile: filename, type: "json")
            deliver(document, to: completion)

        case .delete:
            documents.removeAll { $0.id == id }
            deliver("Deleted", to: completion)

        default:
            fatalError("Unsupported HTTP method for document")
        }
    }

    /// Safely delivers a value to the completion handler, validating its type at runtime.
    @inline(__always) // Hint to the compiler to always inline this small helper for performance.
    private func deliver<Response>(_ value: Any,
                                   to completion: @escaping (Result<Response, GiniError>) -> Void,
                                   file: StaticString = #file, line: UInt = #line) {
        if let typed = value as? Response {
            completion(.success(typed))
        } else {
            // Avoids force-casting
            fatalError("Type mismatch: expected \(Response.self), got \(type(of: value)) at \(file):\(line)")
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
        guard let apiMethod = resource.method as? APIMethod else {
            return
        }

        switch apiMethod {
        case .createDocument(_, _, _, let documentType):
            let mockId = mockIdForDocumentType(documentType)

            guard let typedResponse = mockId as? T.ResponseType else {
                assertionFailure("Mock response type mismatch")
                return
            }

            completion(.success(typedResponse))

        default:
            break
        }
    }

    private func mockIdForDocumentType(_ documentType: Document.TypeV2?) -> Any {
        switch documentType {
        case .none:
            return SessionManagerMock.v1DocumentId
        case .some:
            return SessionManagerMock.partialDocumentId
        }
    }
}
