//
//  PaymentRequestErrorSessionManagerMock.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class PaymentRequestErrorSessionManagerMock: SessionManagerProtocol {
    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void) {}
    func logOut() {}

    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard let apiMethod = resource.method as? APIMethod else {
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }
        switch apiMethod {
        case .createPaymentRequest:
            handleCreatePaymentRequest(resource: resource, completion: completion)
        case .paymentRequests:
            handleBatchDeletePaymentRequests(resource: resource, completion: completion)
        case .paymentRequest(let id):
            handleDeletePaymentRequest(id: id, resource: resource, completion: completion)
        default:
            completion(.failure(.unknown(response: nil, data: nil)))
        }
    }

    private func makeResponse(url: URL, statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(url: url,
                        statusCode: statusCode,
                        httpVersion: "HTTP/1.1",
                        headerFields: ["Content-Type": "application/vnd.gini.v5+json"])
    }

    private func handleCreatePaymentRequest<T: Resource>(resource: T,
                                                         completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        let jsonData = loadFile(withName: "createPaymentRequestMultiErrors", ofType: "json")
        guard let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests") else {
            XCTFail("Invalid URL in request")
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }
        completion(.failure(.customError(response: makeResponse(url: url, statusCode: 400), data: jsonData)))
    }

    private func handleBatchDeletePaymentRequests<T: Resource>(resource: T,
                                                               completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard resource.params.method == .delete else {
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }
        guard let bodyData = resource.params.body,
              let ids = try? JSONDecoder().decode([String].self, from: bodyData) else {
            completion(.failure(.parseError(message: "Failed to decode request body")))
            return
        }

        if ids.isEmpty {
            guard let response = ("" as Any) as? T.ResponseType else {
                completion(.failure(.parseError(message: "Unexpected response type for empty delete")))
                return
            }
            completion(.success(response))
            return
        }

        if ids.allSatisfy({ $0.hasPrefix("forbidden") }) {
            let jsonData = loadFile(withName: "deletePaymentRequestForbiddenError", ofType: "json")
            guard let url = resource.request.url else {
                XCTFail("Invalid URL in request")
                completion(.failure(.unknown(response: nil, data: nil)))
                return
            }
            let response = makeResponse(url: url, statusCode: 403)
            completion(.failure(.customError(response: response, data: jsonData)))
            return
        }

        if ids.count == 3 {
            let jsonData = loadFile(withName: "deletePaymentRequestsMultiErrors", ofType: "json")
            guard let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests") else {
                XCTFail("Invalid URL in request")
                completion(.failure(.unknown(response: nil, data: nil)))
                return
            }
            let response = makeResponse(url: url, statusCode: 400)
            completion(.failure(.customError(response: response, data: jsonData)))
            return
        }

        completion(.failure(.unknown(response: nil, data: nil)))
    }

    private func handleDeletePaymentRequest<T: Resource>(id: String,
                                                         resource: T,
                                                         completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard resource.params.method == .delete else {
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }

        switch id {
        case "forbidden-id":
            handleForbiddenDeletePaymentRequest(id: id, resource: resource, completion: completion)
        case "missing-id":
            handleNotFoundDeletePaymentRequest(id: id, resource: resource, completion: completion)
        default:
            completion(.failure(.unknown(response: nil, data: nil)))
        }
    }

    private func handleForbiddenDeletePaymentRequest<T: Resource>(id: String,
                                                                   resource: T,
                                                                   completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        let jsonData = loadFile(withName: "deletePaymentRequestError", ofType: "json")
        guard let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests/\(id)") else {
            XCTFail("Invalid URL in request")
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }
        completion(.failure(.customError(response: makeResponse(url: url, statusCode: 403), data: jsonData)))
    }

    private func handleNotFoundDeletePaymentRequest<T: Resource>(id: String,
                                                                  resource: T,
                                                                  completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        guard let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests/\(id)") else {
            XCTFail("Invalid URL in request")
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }
        completion(.failure(.notFound(response: makeResponse(url: url, statusCode: 404), data: nil)))
    }

    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        completion(.failure(.unknown(response: nil, data: nil)))
    }

    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        completion(.failure(.unknown(response: nil, data: nil)))
    }
}
