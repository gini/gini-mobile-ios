//
//  GiniHealthSDKIntegrationTestsBase.swift
//  GiniHealthSDKExampleTests
//
//  Base class for Gini Health SDK integration tests
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import UIKit
import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

/// Base class for Gini Health SDK integration tests
/// Provides common setup, teardown, and helper methods
class GiniHealthSDKIntegrationTestsBase: XCTestCase {

    // MARK: - Test Configuration
    
    /// Standard timeout for network operations in integration tests
    let networkTimeout: TimeInterval = 30
    
    /// Extended timeout for long-running operations (document processing, etc.)
    let extendedTimeout: TimeInterval = 60
    
    // When running from Xcode: update these environment variables in the scheme
    // These tests will be skipped if credentials are not provided
    var clientId: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_ID"]
        return value?.isEmpty == false ? value : nil
    }
    
    var clientSecret: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_SECRET"]
        return value?.isEmpty == false ? value : nil
    }

    var giniHealth: GiniHealth!
    var paymentService: PaymentService!
    
    /// Track created payment request IDs for cleanup
    var createdPaymentRequestIds: [String] = []
    
    /// Track created document IDs for cleanup
    var createdDocumentIds: [String] = []

    override func setUp() {
        super.setUp()
        
        // Skip tests if credentials are not provided
        guard let id = clientId, let secret = clientSecret else {
            return // XCTSkip will be called in each test method
        }

        let domain = "health-sdk-integration-tests"

        // Initialize GiniHealth SDK
        giniHealth = GiniHealth(id: id,
                                secret: secret,
                                domain: domain)

        paymentService = giniHealth.paymentService
        createdPaymentRequestIds = []
        createdDocumentIds = []

        print("✅ GiniHealth SDK initialized")
    }
    
    /// Helper to skip tests when credentials are not available
    func skipIfCredentialsMissing() throws {
        guard clientId != nil, clientSecret != nil else {
            throw XCTSkip("Integration test skipped: CLIENT_ID and CLIENT_SECRET environment variables must be set. Configure them in the test scheme or test plan.")
        }
    }
    
    override func tearDown() {
        // Clean up payment requests
        let paymentCleanupExpectation = expectation(description: "cleanup payment requests")
        paymentCleanupExpectation.expectedFulfillmentCount = max(1, createdPaymentRequestIds.count)
        
        if createdPaymentRequestIds.isEmpty {
            paymentCleanupExpectation.fulfill()
        } else {
            for requestId in createdPaymentRequestIds {
                paymentService.deletePaymentRequest(id: requestId) { _ in
                    print("🧹 Cleaned up payment request: \(requestId)")
                    paymentCleanupExpectation.fulfill()
                }
            }
        }
        
        // Clean up documents
        let documentCleanupExpectation = expectation(description: "cleanup documents")
        documentCleanupExpectation.expectedFulfillmentCount = max(1, createdDocumentIds.count)
        
        if createdDocumentIds.isEmpty {
            documentCleanupExpectation.fulfill()
        } else {
            // Note: Document cleanup would require keeping Document objects, not just IDs
            // For now, just fulfill the expectation
            for documentId in createdDocumentIds {
                print("ℹ️ Document cleanup skipped (would need Document object): \(documentId)")
                documentCleanupExpectation.fulfill()
            }
        }
        
        wait(for: [paymentCleanupExpectation, documentCleanupExpectation], timeout: networkTimeout)
        
        super.tearDown()
    }
}
