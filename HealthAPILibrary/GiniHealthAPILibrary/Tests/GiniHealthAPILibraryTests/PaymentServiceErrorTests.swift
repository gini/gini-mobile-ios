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
    private func awaitExpectedFailure<T>(
        description: String,
        timeout: TimeInterval = 1.0,
        action: (@escaping (Result<T, GiniError>) -> Void) -> Void
    ) -> GiniError {
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

    func testCreatePaymentRequest_BadRequest_decodesItemsAndRequestId() {
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
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.requestId, "7cc7-229b-4b88-dd94-3aad-f072")
        let items = error.items ?? []
        XCTAssertEqual(items.count, 3)
        let codes = Set(items.map { $0.code })
        XCTAssertEqual(codes, Set(["2012", "2002", "2007"]))
        let messages = items.compactMap { $0.message }
        XCTAssertTrue(messages.contains("Provide a valid BIC number"))
        XCTAssertTrue(messages.contains("Value of payment purpose should be at least 4, at most 200 characters long"))
        XCTAssertTrue(messages.contains("Provide a valid IBAN number"))
    }

    func testDeletePaymentRequest_Forbidden_decodesItemsAndRequestId() {
        let error = awaitExpectedFailure(description: "delete payment request forbidden") { completion in
            self.service.deletePaymentRequest(id: "forbidden-id", completion: completion)
        }
        XCTAssertEqual(error.statusCode, 403)
        XCTAssertEqual(error.requestId, "7cc7-229b-4b88-dd94-3aad-f072")
        let items = error.items ?? []
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.code, "2901")
        XCTAssertEqual(items.first?.message, "The deletion operation on the payment request is not authorized")
    }

    func testDeletePaymentRequest_NotFound_statusCode404() {
        let error = awaitExpectedFailure(description: "delete payment request not found") { completion in
            self.service.deletePaymentRequest(id: "missing-id", completion: completion)
        }
        XCTAssertEqual(error.statusCode, 404)
        XCTAssertEqual(error.message, "Not found")
        XCTAssertNil(error.items)
    }
    
    func testBatchDeletePaymentRequests_PartialFailure_decodesMultipleErrors() {
        let error = awaitExpectedFailure(description: "batch delete payment requests partial failure") { completion in
            self.service.deletePaymentRequests(["doc1", "doc2", "doc3"], completion: completion)
        }
        XCTAssertEqual(error.statusCode, 400)
        let items = error.items ?? []
        XCTAssertEqual(items.count, 2)
        let codes = Set(items.map { $0.code })
        XCTAssertEqual(codes, Set(["2014", "2013"]))
        XCTAssertEqual(Set(error.objectsWithCode("2014")), Set(["doc2", "doc3"]))
        XCTAssertEqual(error.objectsWithCode("2013"), ["doc1"])
    }
    
    func testBatchDeletePaymentRequests_AllForbidden_returns403() {
        let error = awaitExpectedFailure(description: "batch delete all forbidden") { completion in
            self.service.deletePaymentRequests(["forbidden1", "forbidden2"], completion: completion)
        }
        XCTAssertEqual(error.statusCode, 403)
        let items = error.items ?? []
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.code, "2901")
        XCTAssertEqual(Set(error.objectsWithCode("2901")), Set(["forbidden1", "forbidden2"]))
    }
    
    func testBatchDeletePaymentRequests_EmptyList_handledGracefully() {
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

