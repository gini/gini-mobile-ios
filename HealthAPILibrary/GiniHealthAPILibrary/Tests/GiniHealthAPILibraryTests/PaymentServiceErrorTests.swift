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

    func testCreatePaymentRequest_BadRequest_decodesItemsAndRequestId() {
        // Given
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

