//
//  SessionManagerMock.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2019 Gini. All rights reserved.
//

import Foundation
import XCTest
@testable import GiniHealthAPILibrary

final class SessionManagerMock: SessionManagerProtocol {

    static let v3DocumentId = "626626a0-749f-11e2-bfd6-000000000000"
    static let partialDocumentId = "5e06e343-9dff-4924-99ac-7d5b3abf592c"
    static let compositeDocumentId = "8d0c628d-95e8-4cf2-b4ea-d2daf03d8a32"
    static let paymentProviderId = "b09ef70a-490f-11eb-952e-9bc6f4646c57"
    static let paymentRequestId = "118edf41-102a-4b40-8753-df2f0634cb86"
    static let paymentRequesterUri = "ginipay-test://paymentRequester"

    static let paymentRequestURL = "https://health-api.gini.net/paymentRequests/118edf41-102a-4b40-8753-df2f0634cb86/payment"
    static let paymentID = "b4bd3e80-7bd1-11e4-95ab-000000000000"
    var documents: [Document] = []
    var providersResponse: [PaymentProviderResponse] = []
    var providerResponse: PaymentProviderResponse = load(fromFile: "provider", type: "json")
    var paymentRequests: [PaymentRequest] = []
    var extractionFeedbackBody: Data?

    init(keyStore: KeyStore = KeychainStore(),
         urlSession: URLSession = URLSession(configuration: .default)) {
        /// This method will remain empty; mock implementation does not perform login
    }

    func initializeWithV3MockedDocuments() {
        documents = [
            load(fromFile: "document", type: "json")
        ]
    }

    func initializeWithPaymentProvidersResponse() {
        providersResponse = load(fromFile: "providers", type: "json")
    }

    func initializeWithPaymentRequests() {
        paymentRequests = load(fromFile: "paymentRequests", type: "json")
    }

    func initializeWithV2MockedDocuments() {
        documents = [
            load(fromFile: "partialDocument", type: "json"),
            load(fromFile: "compositeDocument", type: "json")
        ]
    }

    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void) {
        /// This method will remain empty; mock implementation does not perform login
    }

    func logOut() {
        /// This method will remain empty; mock implementation does not perform login
    }

    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard let apiMethod = resource.method as? APIMethod else {
            failFast(description: "Unexpected resource.method \(resource.method) in mock data(...)",
                     completion: completion)
            return
        }

        switch apiMethod {
        case .document(let id):
            handleDocument(id: id,
                           method: resource.params.method,
                           completion: completion)
        case .createDocument:
            deliver(SessionManagerMock.compositeDocumentId, to: completion)
        case .createPaymentRequest:
            deliver(SessionManagerMock.paymentRequestId, to: completion)
        case .paymentProvider:
            let providerResponse: PaymentProviderResponse = load(fromFile: "provider", type: "json")
            deliver(providerResponse, to: completion)
        case .paymentProviders:
            let paymentProvidersResponse: [PaymentProviderResponse] = load(fromFile: "providers", type: "json")
            deliver(paymentProvidersResponse, to: completion)
        case .paymentRequest:
            if resource.params.method == .delete {
                deliver(SessionManagerMock.paymentRequestId, to: completion)
            } else {
                let paymentRequest: PaymentRequest = load(fromFile: "paymentRequest", type: "json")
                deliver(paymentRequest, to: completion)
            }
        case .paymentRequests:
            deliver(paymentRequests, to: completion)
        case .feedback:
            extractionFeedbackBody = resource.request.httpBody
            deliver("Feedback was sent", to: completion)
        case .payment:
            let payment: Payment = load(fromFile: "payment", type: "json")
            deliver(payment, to: completion)
        case .pdfWithQRCode:
            let pdfData = loadFile(withName: "pdfWithQR", ofType: "pdf")
            deliver(pdfData, to: completion)
        default:
            completion(.failure(.unknown(response: nil, data: nil)))
        }
    }

    private func handleDocument<T>(id: String,
                                   method: HTTPMethod,
                                   completion: @escaping CompletionResult<T>) {
        switch (id, method) {
        case (SessionManagerMock.v3DocumentId, .get):
            let document: Document = load(fromFile: "document", type: "json")
            deliver(document, to: completion)
        case (SessionManagerMock.v3DocumentId, .delete):
            documents.removeAll(where: { $0.id == id })
            deliver("Deleted", to: completion)
        case (SessionManagerMock.partialDocumentId, .get):
            let document: Document = load(fromFile: "partialDocument", type: "json")
            deliver(document, to: completion)
        case (SessionManagerMock.partialDocumentId, .delete):
            documents.removeAll(where: { $0.id == id })
            deliver("Deleted", to: completion)
        case (SessionManagerMock.compositeDocumentId, .get):
            let document: Document = load(fromFile: "compositeDocument", type: "json")
            deliver(document, to: completion)
        case (SessionManagerMock.compositeDocumentId, .delete):
            documents.removeAll(where: { $0.id == id })
            deliver("Deleted", to: completion)
        default:
            XCTFail("Document id \(id) not found in tests")
            completion(.failure(.unknown(response: nil, data: nil)))
        }
    }

    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard let apiMethod = resource.method as? APIMethod else {
            failFast(description: "Unexpected resource.method \(resource.method) in mock download(...)",
                     completion: completion)
            return
        }

        switch apiMethod {
        case .file:
            guard let imageData = UIImage(named: "Gini-Test-Payment-Provider",
                                          in: Bundle.module,
                                          compatibleWith: nil)?.pngData() else {
                XCTFail("Gini-Test-Payment-Provider asset missing from test bundle")
                completion(.failure(.unknown(response: nil, data: nil)))
                return
            }
            deliver(imageData, to: completion)
        default:
            break
        }
    }

    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard let apiMethod = resource.method as? APIMethod else {
            failFast(description: "Unexpected resource.method \(resource.method) in mock upload(...)",
                     completion: completion)
            return
        }

        switch apiMethod {
        case .createDocument(_, _, _, let documentType):
            deliver(mockIdForDocumentType(documentType), to: completion)
        default:
            break
        }
    }

    private func mockIdForDocumentType(_ documentType: Document.TypeV2?) -> String {
        switch documentType {
        case .none:
            return SessionManagerMock.v3DocumentId
        case .some:
            return SessionManagerMock.partialDocumentId
        }
    }

    // MARK: - Response routing

    /**
     Deliver `value` to `completion` typed as `Response`. Runtime-checks the cast
     via `as?` and fails-fast on mismatch instead of force-casting — mirrors the
     helper on the Bank API's SessionManagerMock so async tests surface type
     drift as a clear XCTFail rather than a crash.
     */
    private func deliver<Response>(_ value: Any,
                                   to completion: @escaping (Result<Response, GiniError>) -> Void,
                                   file: StaticString = #file,
                                   line: UInt = #line) {
        if let typed = value as? Response {
            completion(.success(typed))
        } else {
            XCTFail("Type mismatch: expected \(Response.self), got \(type(of: value))",
                    file: file, line: line)
            completion(.failure(.parseError(message: "Type mismatch in SessionManagerMock",
                                            response: nil,
                                            data: nil)))
        }
    }

    /**
     Called from the top-level `resource.method as? APIMethod` guards — records
     an XCTFail so unexpected inputs surface immediately, then completes with a
     `.unknown` failure so callers awaiting the completion aren't left hanging.
     */
    private func failFast<T>(description: String,
                             completion: @escaping (Result<T, GiniError>) -> Void,
                             file: StaticString = #file,
                             line: UInt = #line) {
        XCTFail(description, file: file, line: line)
        completion(.failure(.unknown(response: nil, data: nil)))
    }
}
