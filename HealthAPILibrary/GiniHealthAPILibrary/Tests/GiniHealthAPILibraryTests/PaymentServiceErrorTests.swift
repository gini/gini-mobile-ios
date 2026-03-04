import XCTest
@testable import GiniHealthAPILibrary

final class PaymentServiceErrorTests: XCTestCase {

    func testCreatePaymentRequest_BadRequest_decodesItemsAndRequestId() {
        // Given
        let mock = PaymentRequestErrorSessionManagerMock()
        let service = PaymentService(sessionManager: mock, apiVersion: 5)
        let expect = expectation(description: "create payment request failure")
        var capturedError: GiniError?

        // When
        service.createPaymentRequest(sourceDocumentLocation: "",
                                     paymentProvider: "provider-id",
                                     recipient: "John Doe",
                                     iban: "INVALID-IBAN",
                                     bic: "INVALID-BIC",
                                     amount: "1.00:EUR",
                                     purpose: "abc") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                capturedError = error
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)

        // Then
        guard let error = capturedError else {
            return XCTFail("No error captured")
        }
        XCTAssertEqual(error.statusCode, 400, "Status code should be 400 for bad request")
        XCTAssertEqual(error.requestId, "7cc7-229b-4b88-dd94-3aad-f072", "Request ID should be decoded from error body")

        let items = error.items ?? []
        XCTAssertEqual(items.count, 3, "There should be exactly three error items")

        let codes = Set(items.map { $0.code })
        XCTAssertEqual(codes, Set(["2012", "2002", "2007"]))

        // Optional: verify messages for completeness
        let messages = items.compactMap { $0.message }
        XCTAssertTrue(messages.contains("Provide a valid BIC number"))
        XCTAssertTrue(messages.contains("Value of payment purpose should be at least 4, at most 200 characters long"))
        XCTAssertTrue(messages.contains("Provide a valid IBAN number"))
    }

    func testDeletePaymentRequest_Forbidden_decodesItemsAndRequestId() {
        // Given
        let mock = PaymentRequestErrorSessionManagerMock()
        let service = PaymentService(sessionManager: mock, apiVersion: 5)
        let expect = expectation(description: "delete payment request forbidden")
        var capturedError: GiniError?

        // When
        service.deletePaymentRequest(id: "forbidden-id") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                capturedError = error
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)

        // Then
        guard let error = capturedError else {
            return XCTFail("No error captured")
        }
        XCTAssertEqual(error.statusCode, 403, "Status code should be 403 for forbidden delete")
        XCTAssertEqual(error.requestId, "7cc7-229b-4b88-dd94-3aad-f072")

        let items = error.items ?? []
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.code, "2901")
        XCTAssertEqual(items.first?.message, "The deletion operation on the payment request is not authorized")
    }

    func testDeletePaymentRequest_NotFound_statusCode404() {
        // Given
        let mock = PaymentRequestErrorSessionManagerMock()
        let service = PaymentService(sessionManager: mock, apiVersion: 5)
        let expect = expectation(description: "delete payment request not found")
        var capturedError: GiniError?

        // When
        service.deletePaymentRequest(id: "missing-id") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                capturedError = error
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)

        // Then
        guard let error = capturedError else {
            return XCTFail("No error captured")
        }
        XCTAssertEqual(error.statusCode, 404, "Status code should be 404 when payment request does not exist")
        XCTAssertEqual(error.message, "Not found")
        XCTAssertNil(error.items, "Items should be nil when no JSON body is provided")
    }
    
    func testBatchDeletePaymentRequests_PartialFailure_decodesMultipleErrors() {
        // Given
        let mock = PaymentRequestErrorSessionManagerMock()
        let service = PaymentService(sessionManager: mock, apiVersion: 5)
        let expect = expectation(description: "batch delete payment requests partial failure")
        var capturedError: GiniError?
        
        // When
        service.deletePaymentRequests(["doc1", "doc2", "doc3"]) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                capturedError = error
            }
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
        
        // Then
        guard let error = capturedError else {
            return XCTFail("No error captured")
        }
        XCTAssertEqual(error.statusCode, 400, "Status code should be 400 for batch operation with errors")
        
        let items = error.items ?? []
        XCTAssertEqual(items.count, 2, "There should be exactly two error items")
        
        // Verify error codes
        let codes = Set(items.map { $0.code })
        XCTAssertEqual(codes, Set(["2014", "2013"]))
        
        // Verify affected objects
        let notFoundDocs = error.objectsWithCode("2014")
        XCTAssertEqual(Set(notFoundDocs), Set(["doc2", "doc3"]), "doc2 and doc3 should be not found")
        
        let unauthorizedDocs = error.objectsWithCode("2013")
        XCTAssertEqual(unauthorizedDocs, ["doc1"], "doc1 should be unauthorized")
    }
    
    func testBatchDeletePaymentRequests_AllForbidden_returns403() {
        // Given
        let mock = PaymentRequestErrorSessionManagerMock()
        let service = PaymentService(sessionManager: mock, apiVersion: 5)
        let expect = expectation(description: "batch delete all forbidden")
        var capturedError: GiniError?
        
        // When
        service.deletePaymentRequests(["forbidden1", "forbidden2"]) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                capturedError = error
            }
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
        
        // Then
        guard let error = capturedError else {
            return XCTFail("No error captured")
        }
        XCTAssertEqual(error.statusCode, 403)
        
        let items = error.items ?? []
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.code, "2901")
        
        let forbiddenDocs = error.objectsWithCode("2901")
        XCTAssertEqual(Set(forbiddenDocs), Set(["forbidden1", "forbidden2"]))
    }
    
    func testBatchDeletePaymentRequests_EmptyList_handledGracefully() {
        // Given
        let mock = PaymentRequestErrorSessionManagerMock()
        let service = PaymentService(sessionManager: mock, apiVersion: 5)
        let expect = expectation(description: "batch delete empty list")
        var capturedResult: Result<[String], GiniError>?
        
        // When
        service.deletePaymentRequests([]) { result in
            capturedResult = result
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1.0)
        
        // Then
        guard let result = capturedResult else {
            return XCTFail("No result captured")
        }
        
        switch result {
        case .success(let ids):
            XCTAssertEqual(ids, [], "Empty list should succeed with empty result")
        case .failure:
            XCTFail("Empty list should not fail")
        }
    }
}

private final class PaymentRequestErrorSessionManagerMock: SessionManagerProtocol {
    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void) {}
    func logOut() {}

    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .createPaymentRequest:
                let jsonData = """
                {
                  "items": [
                    {
                      "code": "2012",
                      "message": "Provide a valid BIC number"
                    },
                    {
                      "code": "2002",
                      "message": "Value of payment purpose should be at least 4, at most 200 characters long"
                    },
                    {
                      "code": "2007",
                      "message": "Provide a valid IBAN number"
                    }
                  ],
                  "requestId": "7cc7-229b-4b88-dd94-3aad-f072"
                }
                """.data(using: .utf8)!

                let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests")!
                let response = HTTPURLResponse(url: url,
                                               statusCode: 400,
                                               httpVersion: "HTTP/1.1",
                                               headerFields: ["Content-Type": "application/vnd.gini.v5+json"])!
                completion(.failure(.customError(response: response, data: jsonData)))
                
            case .paymentRequests:
                // Handle batch delete
                if resource.params.method == .delete {
                    // Decode the IDs from request body
                    guard let bodyData = resource.params.body,
                          let ids = try? JSONDecoder().decode([String].self, from: bodyData) else {
                        completion(.failure(.parseError(message: "Failed to decode request body")))
                        return
                    }
                    
                    // Empty list case - success
                    if ids.isEmpty {
                        if let result = "" as? T.ResponseType {
                            completion(.success(result))
                        }
                        return
                    }
                    
                    // All forbidden case
                    if ids.allSatisfy({ $0.hasPrefix("forbidden") }) {
                        let jsonData = """
                        {
                          "items": [
                            {
                              "code": "2901",
                              "message": "The deletion operation on the payment request is not authorized",
                              "object": \(String(data: try! JSONEncoder().encode(ids), encoding: .utf8)!)
                            }
                          ],
                          "requestId": "7cc7-229b-4b88-dd94-3aad-f072"
                        }
                        """.data(using: .utf8)!
                        
                        let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests")!
                        let response = HTTPURLResponse(url: url,
                                                       statusCode: 403,
                                                       httpVersion: "HTTP/1.1",
                                                       headerFields: ["Content-Type": "application/vnd.gini.v5+json"])!
                        completion(.failure(.customError(response: response, data: jsonData)))
                        return
                    }
                    
                    // Partial failure case - mixed errors
                    if ids.count == 3 {
                        let jsonData = """
                        {
                          "items": [
                            {
                              "code": "2013",
                              "message": "Unauthorized access to payment request",
                              "object": ["doc1"]
                            },
                            {
                              "code": "2014",
                              "message": "Payment request not found",
                              "object": ["doc2", "doc3"]
                            }
                          ],
                          "requestId": "7cc7-229b-4b88-dd94-3aad-f072"
                        }
                        """.data(using: .utf8)!
                        
                        let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests")!
                        let response = HTTPURLResponse(url: url,
                                                       statusCode: 400,
                                                       httpVersion: "HTTP/1.1",
                                                       headerFields: ["Content-Type": "application/vnd.gini.v5+json"])!
                        completion(.failure(.customError(response: response, data: jsonData)))
                        return
                    }
                }
                completion(.failure(.unknown(response: nil, data: nil)))
                
            case .paymentRequest(let id):
                // Simulate delete responses based on the provided ID
                if resource.params.method == .delete && id == "forbidden-id" {
                    let jsonData = """
                    {
                      "items": [
                        {
                          "code": "2901",
                          "message": "The deletion operation on the payment request is not authorized"
                        }
                      ],
                      "requestId": "7cc7-229b-4b88-dd94-3aad-f072"
                    }
                    """.data(using: .utf8)!

                    let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests/\(id)")!
                    let response = HTTPURLResponse(url: url,
                                                   statusCode: 403,
                                                   httpVersion: "HTTP/1.1",
                                                   headerFields: ["Content-Type": "application/vnd.gini.v5+json"])!
                    completion(.failure(.customError(response: response, data: jsonData)))
                    return
                }

                if resource.params.method == .delete && id == "missing-id" {
                    let url = resource.request.url ?? URL(string: "https://health-api.gini.net/paymentRequests/\(id)")!
                    let response = HTTPURLResponse(url: url,
                                                   statusCode: 404,
                                                   httpVersion: "HTTP/1.1",
                                                   headerFields: ["Content-Type": "application/vnd.gini.v5+json"])!
                    completion(.failure(.notFound(response: response, data: nil)))
                    return
                }

                completion(.failure(.unknown(response: nil, data: nil)))
            default:
                completion(.failure(.unknown(response: nil, data: nil)))
            }
        } else {
            completion(.failure(.unknown(response: nil, data: nil)))
        }
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
