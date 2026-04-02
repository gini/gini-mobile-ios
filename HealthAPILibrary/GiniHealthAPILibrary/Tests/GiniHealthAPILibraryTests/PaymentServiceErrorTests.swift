//
//  PaymentServiceErrorTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class PaymentServiceErrorTests: XCTestCase {

    var mock: PaymentRequestErrorSessionManagerMock!
    var service: PaymentService!

    override func setUp() {
        super.setUp()
        mock = PaymentRequestErrorSessionManagerMock()
        service = PaymentService(sessionManager: mock, apiVersion: 5)
    }

    override func tearDown() {
        service = nil
        mock = nil
        super.tearDown()
    }

    // MARK: - Helper

    @discardableResult
    private func awaitExpectedFailure<T>(description: String,
                                         timeout: TimeInterval = 1.0,
                                         action: (@escaping (Result<T, GiniError>) -> Void) -> Void) -> GiniError {
        let exp = expectation(description: description)
        var capturedError: GiniError?
        action { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                capturedError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: timeout)
        guard let error = capturedError else {
            XCTFail("No error captured for: \(description)")
            return .unknown(response: nil, data: nil)
        }
        return error
    }

    func testCreatePaymentRequestBadRequestDecodesItemsAndRequestId() {
        let error = awaitExpectedFailure(description: "create payment request failure") { completion in
            self.service.createPaymentRequest(sourceDocumentLocation: "",
                                             paymentProvider: "provider-id",
                                             recipient: "John Doe",
                                             iban: "INVALID-IBAN",
                                             bic: "INVALID-BIC",
                                             amount: "1.00:EUR",
                                             purpose: "abc",
                                             completion: completion)
        }
        XCTAssertEqual(error.statusCode, 400, "Status code should be 400 for bad request")
        XCTAssertEqual(error.requestId, "7cc7-229b-4b88-dd94-3aad-f072", "Request ID should match")
        let items = error.items ?? []
        XCTAssertEqual(items.count, 3, "There should be 3 error items")
        let codes = Set(items.map { $0.code })
        XCTAssertEqual(codes, Set(["2012", "2002", "2007"]), "Error codes should match")
        let messages = items.compactMap { $0.message }
        XCTAssertTrue(messages.contains("Provide a valid BIC number"), "BIC validation message should be present")
        XCTAssertTrue(messages.contains("Value of payment purpose should be at least 4, at most 200 characters long"), "Payment purpose validation message should be present")
        XCTAssertTrue(messages.contains("Provide a valid IBAN number"), "IBAN validation message should be present")
    }

    func testDeletePaymentRequestForbiddenDecodesItemsAndRequestId() {
        let error = awaitExpectedFailure(description: "delete payment request forbidden") { completion in
            self.service.deletePaymentRequest(id: "forbidden-id", completion: completion)
        }
        XCTAssertEqual(error.statusCode, 403, "Status code should be 403 for forbidden")
        XCTAssertEqual(error.requestId, "7cc7-229b-4b88-dd94-3aad-f072", "Request ID should match")
        let items = error.items ?? []
        XCTAssertEqual(items.count, 1, "There should be 1 error item")
        XCTAssertEqual(items.first?.code, "2901", "Error code should be 2901")
        XCTAssertEqual(items.first?.message, "The deletion operation on the payment request is not authorized", "Error message should match")
    }

    func testDeletePaymentRequestNotFoundStatusCode404() {
        let error = awaitExpectedFailure(description: "delete payment request not found") { completion in
            self.service.deletePaymentRequest(id: "missing-id", completion: completion)
        }
        XCTAssertEqual(error.statusCode, 404, "Status code should be 404 for not found")
        XCTAssertEqual(error.message, "Not found", "Error message should be 'Not found'")
        XCTAssertNil(error.items, "Items should be nil for a simple not-found error")
    }
    
    func testBatchDeletePaymentRequestsPartialFailureDecodesMultipleErrors() {
        let error = awaitExpectedFailure(description: "batch delete payment requests partial failure") { completion in
            self.service.deletePaymentRequests(["doc1", "doc2", "doc3"], completion: completion)
        }
        XCTAssertEqual(error.statusCode, 400, "Status code should be 400 for partial failure")
        let items = error.items ?? []
        XCTAssertEqual(items.count, 2, "There should be 2 error items")
        let codes = Set(items.map { $0.code })
        XCTAssertEqual(codes, Set(["2014", "2013"]), "Error codes should match")
        XCTAssertEqual(Set(error.objectsWithCode("2014")), Set(["doc2", "doc3"]), "Objects for code 2014 should match")
        XCTAssertEqual(error.objectsWithCode("2013"), ["doc1"], "Objects for code 2013 should match")
    }
    
    func testBatchDeletePaymentRequestsAllForbiddenReturns403() {
        let error = awaitExpectedFailure(description: "batch delete all forbidden") { completion in
            self.service.deletePaymentRequests(["forbidden1", "forbidden2"], completion: completion)
        }
        XCTAssertEqual(error.statusCode, 403, "Status code should be 403 for all-forbidden batch delete")
        let items = error.items ?? []
        XCTAssertEqual(items.count, 1, "There should be 1 error item")
        XCTAssertEqual(items.first?.code, "2901", "Error code should be 2901")
        XCTAssertEqual(Set(error.objectsWithCode("2901")), Set(["forbidden1", "forbidden2"]), "Forbidden objects should match")
    }
    
    func testBatchDeletePaymentRequestsEmptyListHandledGracefully() {
        // Given
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

