//
//  GiniHealthSDKPaymentRequestTests.swift
//  GiniHealthSDKExampleTests
//
//  Integration tests for Payment Request operations
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import UIKit
import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

/// Integration tests for Payment Request operations
final class GiniHealthSDKPaymentRequestTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - Payment Request Tests

    func testCreatePaymentRequest() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "fetch providers")
        let expectRequest = expectation(description: "create payment request")

        var paymentProviderId: String?

        // First fetch a payment provider
        paymentService.paymentProviders { result in
            switch result {
            case .success(let providers):
                paymentProviderId = providers.first?.id
                print("✅ Selected provider for test")
            case .failure(let error):
                XCTFail("Failed to fetch providers: \(error)")
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: networkTimeout)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Create payment request with real provider ID
        paymentService.createPaymentRequest(
            sourceDocumentLocation: nil,
            paymentProvider: providerId,
            recipient: "Dr. med. Test",
            iban: "DE89370400440532013000",
            bic: nil,
            amount: "42.50:EUR",
            purpose: "Test Invoice #\(Int.random(in: 1000...9999))"
        ) { result in
            switch result {
            case .success(let requestId):
                XCTAssertFalse(requestId.isEmpty)
                self.createdPaymentRequestIds.append(requestId)  // Track for cleanup
                print("✅ Created payment request: \(requestId)")
            case .failure(let error):
                XCTFail("Failed to create payment request: \(error)")
            }
            expectRequest.fulfill()
        }

        wait(for: [expectRequest], timeout: networkTimeout)
    }

    func testGetPaymentRequest() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "fetch providers")
        let expectCreate = expectation(description: "create payment request")
        let expectGet = expectation(description: "get payment request")

        var paymentProviderId: String?
        var requestId: String?
        let testRecipient = "Dr. med. GetTest"
        let testAmount = "99.99:EUR"
        let testIban = "DE89370400440532013000"

        // 1. Fetch payment provider
        paymentService.paymentProviders { result in
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

        // 2. Create payment request
        paymentService.createPaymentRequest(
            sourceDocumentLocation: nil,
            paymentProvider: providerId,
            recipient: testRecipient,
            iban: testIban,
            bic: nil,
            amount: testAmount,
            purpose: "Test Get Payment Request"
        ) { result in
            if case .success(let id) = result {
                requestId = id
                self.createdPaymentRequestIds.append(id)  // Track for cleanup
                print("✅ Created payment request: \(id)")
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: networkTimeout)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // 3. Get payment request by ID and verify content
        paymentService.paymentRequest(id: id) { result in
            switch result {
            case .success(let request):
                XCTAssertEqual(request.recipient, testRecipient, "Recipient should match")
                XCTAssertEqual(request.iban, testIban, "IBAN should match")
                XCTAssertEqual(request.amount, testAmount, "Amount should match")
                print("✅ Retrieved and validated payment request")
            case .failure(let error):
                XCTFail("Failed to get payment request: \(error)")
            }
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: networkTimeout)
    }

    func testPaymentRequestLifecycle() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "1. fetch providers")
        let expectCreate = expectation(description: "2. create payment request")
        let expectGet = expectation(description: "3. get payment request")
        let expectDelete = expectation(description: "4. delete payment request")

        var paymentProviderId: String?
        var requestId: String?

        // Step 1: Fetch payment provider
        paymentService.paymentProviders { result in
            if case .success(let providers) = result {
                paymentProviderId = providers.first?.id
                print("✅ Step 1/4: Got provider ID")
            }
            expectProviders.fulfill()
        }

        wait(for: [expectProviders], timeout: networkTimeout)

        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }

        // Step 2: Create payment request
        paymentService.createPaymentRequest(
            sourceDocumentLocation: nil,
            paymentProvider: providerId,
            recipient: "Dr. med. Lifecycle",
            iban: "DE89370400440532013000",
            bic: nil,
            amount: "123.45:EUR",
            purpose: "Lifecycle Test #\(Int.random(in: 1000...9999))"
        ) { result in
            if case .success(let id) = result {
                requestId = id
                print("✅ Step 2/4: Created payment request: \(id)")
            }
            expectCreate.fulfill()
        }

        wait(for: [expectCreate], timeout: networkTimeout)

        guard let id = requestId else {
            XCTFail("Payment request not created")
            return
        }

        // Step 3: Verify it exists
        paymentService.paymentRequest(id: id) { result in
            switch result {
            case .success(let request):
                XCTAssertEqual(request.recipient, "Dr. med. Lifecycle")
                XCTAssertEqual(request.amount, "123.45:EUR")
                print("✅ Step 3/4: Payment request exists and validated")
            case .failure(let error):
                XCTFail("Failed to get payment request: \(error)")
            }
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: networkTimeout)

        // Step 4: Delete it
        giniHealth.deletePaymentRequest(id: id) { result in
            switch result {
            case .success:
                print("✅ Step 4/4: Payment request deleted successfully")
            case .failure(let error):
                XCTFail("Failed to delete payment request: \(error)")
            }
            expectDelete.fulfill()
        }

        wait(for: [expectDelete], timeout: networkTimeout)
    }
}
