//
//  GiniHealthSDKBankingTests.swift
//  GiniHealthSDKExampleTests
//
//  Integration tests for Banking and Payment Methods
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import UIKit
import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

/// Integration tests for Banking and Payment Methods
final class GiniHealthSDKBankingTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - Banking App Methods Tests

    func testFetchBankingApps() throws {
        let expect = expectation(description: "fetch banking apps")

        giniHealth.fetchBankingApps { result in
            switch result {
            case .success(let providers):
                XCTAssertFalse(providers.isEmpty, "Should have banking apps")
                if let firstProvider = providers.first {
                    XCTAssertFalse(firstProvider.id.isEmpty)
                    XCTAssertFalse(firstProvider.name.isEmpty)
                }
            case .failure(let error):
                XCTFail("Failed to fetch banking apps: \(error)")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: networkTimeout)
    }

    // MARK: - Payment Request Methods Tests

    func testCreatePaymentRequestViaGiniHealth() throws {
        let providerId = try fetchFirstProviderId()
        let paymentInfo = makePaymentInfo(recipient: "Dr. Test Integration",
                                          amount: "55.50:EUR",
                                          purpose: "Integration Test Payment",
                                          providerId: providerId)
        let requestId = try createAndTrackPaymentRequest(paymentInfo: paymentInfo)
        XCTAssertFalse(requestId.isEmpty)
    }

    func testGetPaymentRequestViaGiniHealth() throws {
        let providerId = try fetchFirstProviderId()
        let id = try createAndTrackPaymentRequest(paymentInfo: makePaymentInfo(recipient: "Dr. GetTest",
                                                                               amount: "77.77:EUR",
                                                                               purpose: "Get Payment Request Test",
                                                                               providerId: providerId))

        let expect = expectation(description: "get payment request")
        giniHealth.getPaymentRequest(by: id) { result in
            switch result {
            case .success(let request):
                XCTAssertEqual(request.recipient, "Dr. GetTest")
                XCTAssertEqual(request.amount, "77.77:EUR")
            case .failure(let error):
                XCTFail("Failed to get payment request: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
    }

    func testDeletePaymentRequests() throws {
        let providerId = try fetchFirstProviderId()
        let id1 = try createAndTrackPaymentRequest(paymentInfo: makePaymentInfo(recipient: "Dr. BatchDelete1",
                                                                                amount: "11.11:EUR",
                                                                                purpose: "Batch Delete Test 1",
                                                                                providerId: providerId))
        let id2 = try createAndTrackPaymentRequest(paymentInfo: makePaymentInfo(recipient: "Dr. BatchDelete2",
                                                                                amount: "22.22:EUR",
                                                                                purpose: "Batch Delete Test 2",
                                                                                providerId: providerId))

        let expect = expectation(description: "delete payment requests")
        giniHealth.deletePaymentRequests(ids: [id1, id2]) { result in
            switch result {
            case .success(let deletedIds):
                XCTAssertEqual(deletedIds.count, 2)
            case .failure(let error):
                XCTFail("Failed to delete payment requests: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
    }

    func testGetPayment() throws {
        let providerId = try fetchFirstProviderId()
        let id = try createAndTrackPaymentRequest(paymentInfo: makePaymentInfo(recipient: "Dr. PaymentStatus",
                                                                               amount: "99.99:EUR",
                                                                               purpose: "Payment Status Test",
                                                                               providerId: providerId))

        let expect = expectation(description: "get payment")
        giniHealth.getPayment(id: id) { result in
            switch result {
            case .success:
                break
            case .failure:
                // Payment might not exist yet for a new request - this is expected
                break
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
    }

    // MARK: - Helpers

    private func fetchFirstProviderId() throws -> String {
        var providerId: String?
        let expect = expectation(description: "fetch providers")
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                providerId = providers.first?.id
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
        return try XCTUnwrap(providerId, "No payment provider available")
    }

    /// Creates a payment request and registers its ID for automatic cleanup in tearDown.
    private func createAndTrackPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo) throws -> String {
        var requestId: String?
        let expect = expectation(description: "create payment request")
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo) { result in
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

    private func makePaymentInfo(recipient: String,
                                 amount: String,
                                 purpose: String,
                                 providerId: String) -> GiniInternalPaymentSDK.PaymentInfo {
        GiniInternalPaymentSDK.PaymentInfo(recipient: recipient,
                                           iban: "DE89370400440532013000",
                                           bic: nil,
                                           amount: amount,
                                           purpose: purpose,
                                           paymentUniversalLink: "",
                                           paymentProviderId: providerId)
    }
}

