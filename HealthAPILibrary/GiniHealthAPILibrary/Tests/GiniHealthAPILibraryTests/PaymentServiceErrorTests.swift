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
