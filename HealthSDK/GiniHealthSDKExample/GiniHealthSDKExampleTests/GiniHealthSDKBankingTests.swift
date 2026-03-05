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

    /// Test fetching banking apps
    func testFetchBankingApps() throws {
        try skipIfCredentialsMissing()
        
        let expect = expectation(description: "fetch banking apps")

        giniHealth.fetchBankingApps { result in
            switch result {
            case .success(let providers):
                XCTAssertFalse(providers.isEmpty, "Should have banking apps")
                print("✅ Fetched \(providers.count) banking apps")

                // Verify provider structure
                if let firstProvider = providers.first {
                    XCTAssertFalse(firstProvider.id.isEmpty)
                    XCTAssertFalse(firstProvider.name.isEmpty)
                    print("✅ Banking app validated: '\(firstProvider.name)'")
                }

            case .failure(let error):
                XCTFail("Failed to fetch banking apps: \(error)")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: networkTimeout)
    }

    // MARK: - Payment Request Methods Tests

    /// Test creating payment request using GiniHealth method
    func testCreatePaymentRequestViaGiniHealth() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")

        var paymentProviderId: String?

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: networkTimeout)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment info
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(
            recipient: "Dr. Test Integration",
            iban: "DE89370400440532013000",
            bic: nil,
            amount: "55.50:EUR",
            purpose: "Integration Test Payment",
            paymentUniversalLink: "",
            paymentProviderId: providerId
        )

        // Create payment request
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo) { result in
            switch result {
            case .success(let requestId):
                XCTAssertFalse(requestId.isEmpty)
                print("✅ Payment request created via GiniHealth: \(requestId)")

                // Cleanup
                self.giniHealth.deletePaymentRequest(id: requestId) { _ in }

            case .failure(let error):
                XCTFail("Failed to create payment request: \(error)")
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: networkTimeout)
    }

    /// Test getting payment request via GiniHealth
    func testGetPaymentRequestViaGiniHealth() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")
        let expectGet = expectation(description: "get payment request")

        var paymentProviderId: String?
        var requestId: String?

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: networkTimeout)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment request
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(
            recipient: "Dr. GetTest",
            iban: "DE89370400440532013000",
            bic: nil,
            amount: "77.77:EUR",
            purpose: "Get Payment Request Test",
            paymentUniversalLink: "",
            paymentProviderId: providerId
        )

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo) { result in
            if case .success(let id) = result {
                requestId = id
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: networkTimeout)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // Get payment request
        giniHealth.getPaymentRequest(by: id) { result in
            switch result {
            case .success(let request):
                XCTAssertEqual(request.recipient, "Dr. GetTest")
                XCTAssertEqual(request.amount, "77.77:EUR")
                print("✅ Payment request retrieved via GiniHealth")

                // Cleanup
                self.giniHealth.deletePaymentRequest(id: id) { _ in }

            case .failure(let error):
                XCTFail("Failed to get payment request: \(error)")
            }
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: networkTimeout)
    }

    /// Test deleting batch of payment requests
    func testDeletePaymentRequests() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate1 = expectation(description: "create payment request 1")
        let expectCreate2 = expectation(description: "create payment request 2")
        let expectDelete = expectation(description: "delete payment requests")

        var paymentProviderId: String?
        var requestIds: [String] = []

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: networkTimeout)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create first payment request
        let paymentInfo1 = GiniInternalPaymentSDK.PaymentInfo(
            recipient: "Dr. BatchDelete1",
            iban: "DE89370400440532013000",
            bic: nil,
            amount: "11.11:EUR",
            purpose: "Batch Delete Test 1",
            paymentUniversalLink: "",
            paymentProviderId: providerId
        )

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo1) { result in
            if case .success(let id) = result {
                requestIds.append(id)
            }
            expectCreate1.fulfill()
        }

        // Create second payment request
        let paymentInfo2 = GiniInternalPaymentSDK.PaymentInfo(
            recipient: "Dr. BatchDelete2",
            iban: "DE89370400440532013000",
            bic: nil,
            amount: "22.22:EUR",
            purpose: "Batch Delete Test 2",
            paymentUniversalLink: "",
            paymentProviderId: providerId
        )

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo2) { result in
            if case .success(let id) = result {
                requestIds.append(id)
            }
            expectCreate2.fulfill()
        }

        wait(for: [expectCreate1, expectCreate2], timeout: networkTimeout)

        guard requestIds.count == 2 else {
            XCTFail("Not all payment requests created")
            return
        }

        // Delete batch
        giniHealth.deletePaymentRequests(ids: requestIds) { result in
            switch result {
            case .success(let deletedIds):
                XCTAssertEqual(deletedIds.count, 2)
                print("✅ Batch deleted \(deletedIds.count) payment requests")
            case .failure(let error):
                XCTFail("Failed to delete payment requests: \(error)")
            }
            expectDelete.fulfill()
        }

        wait(for: [expectDelete], timeout: networkTimeout)
    }

    /// Test getting payment status
    func testGetPayment() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")
        let expectGetPayment = expectation(description: "get payment")

        var paymentProviderId: String?
        var requestId: String?

        // Get provider
        giniHealth.fetchBankingApps { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: networkTimeout)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment request
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(
            recipient: "Dr. PaymentStatus",
            iban: "DE89370400440532013000",
            bic: nil,
            amount: "99.99:EUR",
            purpose: "Payment Status Test",
            paymentUniversalLink: "",
            paymentProviderId: providerId
        )

        giniHealth.createPaymentRequest(paymentInfo: paymentInfo) { result in
            if case .success(let id) = result {
                requestId = id
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: networkTimeout)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // Try to get payment (may not exist yet, which is ok)
        giniHealth.getPayment(id: id) { result in
            switch result {
            case .success(let payment):
                print("✅ Payment retrieved: \(payment)")
            case .failure(let error):
                // Payment might not exist yet for new request - this is expected
                print("⚠️ Payment not found (expected for new request): \(error)")
            }

            // Cleanup
            self.giniHealth.deletePaymentRequest(id: id) { _ in }
            expectGetPayment.fulfill()
        }

        wait(for: [expectGetPayment], timeout: networkTimeout)
    }
}
