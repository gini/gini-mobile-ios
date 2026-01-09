//
//  SessionManagerMock.swift
//  GiniHealthAPI-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/26/19.
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
    var providerResponse: PaymentProviderResponse =  loadProviderResponse()
    var paymentRequests: [PaymentRequest] = []
    var extractionFeedbackBody: Data?


    init(keyStore: KeyStore = KeychainStore(),
         urlSession: URLSession = URLSession(configuration: .default)) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func initializeWithV3MockedDocuments() {
        documents = [
            load(fromFile: "document", type: "json")
        ]
    }
    
    func initializeWithPaymentProvidersResponse() {
        providersResponse = loadProvidersResponse()
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
                switch (id, resource.params.method) {
                case (SessionManagerMock.v3DocumentId, .get):
                    let document: Document = load(fromFile: "document", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (SessionManagerMock.v3DocumentId, .delete):
                    documents.removeAll(where: { $0.id == id })
                    completion(.success("Deleted" as! T.ResponseType))
                case (SessionManagerMock.partialDocumentId, .get):
                    let document: Document = load(fromFile: "partialDocument", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (SessionManagerMock.partialDocumentId, .delete):
                    documents.removeAll(where: { $0.id == id })
                    completion(.success("Deleted" as! T.ResponseType))
                case (SessionManagerMock.compositeDocumentId, .get):
                    let document: Document = load(fromFile: "compositeDocument", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (SessionManagerMock.compositeDocumentId, .delete):
                    documents.removeAll(where: { $0.id == id })
                    completion(.success("Deleted" as! T.ResponseType))
                default:
                    fatalError("Document id not found in tests")
                }
            case .createDocument(_, _, _, _):
                completion(.success(SessionManagerMock.compositeDocumentId as! T.ResponseType))
            case .createPaymentRequest:
                completion(.success(SessionManagerMock.paymentRequestId as! T.ResponseType))
            case .paymentProvider(_):
                let providerResponse: PaymentProviderResponse = loadProviderResponse()
                completion(.success(providerResponse as! T.ResponseType))
            case .paymentProviders:
                let paymentProvidersResponse: [PaymentProviderResponse] = loadProvidersResponse()
                completion(.success(paymentProvidersResponse as! T.ResponseType))
            case .paymentRequest(_):
                if resource.params.method == .delete {
                    completion(.success(SessionManagerMock.paymentRequestId as! T.ResponseType))
                } else {
                    let paymentRequest: PaymentRequest = loadPaymentRequest()
                    completion(.success(paymentRequest as! T.ResponseType))
                }
            case .feedback(_):
                extractionFeedbackBody = resource.request.httpBody ?? nil
                completion(.success("Feedback was sent" as! T.ResponseType))
            case .payment(_):
                let payment: Payment = loadPayment()
                completion(.success(payment as! T.ResponseType))
            case .pdfWithQRCode(_,_):
                let pdfData = loadFile(withName: "pdfWithQR", ofType: "pdf")
                    completion(.success(pdfData as! T.ResponseType))
            default:
                let error = GiniError.unknown(response: nil, data: nil)
                completion(.failure(error))
            }
        }
    }
    
    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .file(_):
                let imageData = UIImage(named: "Gini-Test-Payment-Provider",
                                        in: Bundle.module,
                                        compatibleWith: nil)?.pngData()
                completion(.success(imageData as! T.ResponseType))
            default:
                break
            }
        }
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
            return SessionManagerMock.v3DocumentId
        case .some:
            return SessionManagerMock.partialDocumentId
        }
    }
}
