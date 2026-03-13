//
//  GiniHealthSDKPaymentRequestTests.swift
//  GiniHealthSDKExampleTests
//
//  Integration tests for Payment Request operations
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary

/// Integration tests for Payment Request operations
final class GiniHealthSDKPaymentRequestTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - Payment Request Tests

    func testCreatePaymentRequest() throws {
        let providerId = try fetchFirstProviderId()
        let requestId = try createAndTrackPaymentRequest(recipient: "Dr. med. Test",
                                                         amount: "42.50:EUR",
                                                         purpose: "Test Invoice #\(Int.random(in: 1000...9999))",
                                                         providerId: providerId)
        XCTAssertFalse(requestId.isEmpty)
    }

    func testGetPaymentRequest() throws {
        let testRecipient = "Dr. med. GetTest"
        let testAmount = "99.99:EUR"
        let testIban = "DE89370400440532013000"

        let providerId = try fetchFirstProviderId()
        let id = try createAndTrackPaymentRequest(recipient: testRecipient,
                                                   iban: testIban,
                                                   amount: testAmount,
                                                   purpose: "Test Get Payment Request",
                                                   providerId: providerId)

        let expect = expectation(description: "get payment request")
        paymentService.paymentRequest(id: id) { result in
            switch result {
            case .success(let request):
                XCTAssertEqual(request.recipient, testRecipient, "Recipient should match")
                XCTAssertEqual(request.iban, testIban, "IBAN should match")
                XCTAssertEqual(request.amount, testAmount, "Amount should match")
            case .failure(let error):
                XCTFail("Failed to get payment request: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
    }

    func testPaymentRequestLifecycle() throws {
        let providerId = try fetchFirstProviderId()
        let id = try createAndTrackPaymentRequest(recipient: "Dr. med. Lifecycle",
                                                   amount: "123.45:EUR",
                                                   purpose: "Lifecycle Test #\(Int.random(in: 1000...9999))",
                                                   providerId: providerId)

        let expectGet = expectation(description: "get payment request")
        paymentService.paymentRequest(id: id) { result in
            switch result {
            case .success(let request):
                XCTAssertEqual(request.recipient, "Dr. med. Lifecycle")
                XCTAssertEqual(request.amount, "123.45:EUR")
            case .failure(let error):
                XCTFail("Failed to get payment request: \(error)")
            }
            expectGet.fulfill()
        }
        wait(for: [expectGet], timeout: networkTimeout)

        let expectDelete = expectation(description: "delete payment request")
        giniHealth.deletePaymentRequest(id: id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Failed to delete payment request: \(error)")
            }
            expectDelete.fulfill()
        }
        wait(for: [expectDelete], timeout: networkTimeout)
    }

    // MARK: - Helpers

    private func fetchFirstProviderId() throws -> String {
        var providerId: String?
        let expect = expectation(description: "fetch providers")
        paymentService.paymentProviders { result in
            if case .success(let providers) = result {
                providerId = providers.first?.id
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
        return try XCTUnwrap(providerId, "No payment provider available")
    }

    /// Creates a payment request and registers its ID for automatic cleanup in tearDown.
    private func createAndTrackPaymentRequest(recipient: String,
                                              iban: String = "DE89370400440532013000",
                                              amount: String,
                                              purpose: String,
                                              providerId: String) throws -> String {
        var requestId: String?
        let expect = expectation(description: "create payment request")
        paymentService.createPaymentRequest(sourceDocumentLocation: nil,
                                            paymentProvider: providerId,
                                            recipient: recipient,
                                            iban: iban,
                                            bic: nil,
                                            amount: amount,
                                            purpose: purpose) { result in
            if case .success(let id) = result {
                requestId = id
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
        let id = try XCTUnwrap(requestId, "Payment request not created")
        createdPaymentRequestIds.append(id)
        return id
    }
}
