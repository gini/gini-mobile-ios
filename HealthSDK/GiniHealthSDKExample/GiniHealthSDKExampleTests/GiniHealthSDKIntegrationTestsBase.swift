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
@testable import GiniHealthSDKExample

/// Base class for Gini Health SDK integration tests
/// Provides common setup, teardown, and helper methods
class GiniHealthSDKIntegrationTestsBase: XCTestCase {

    // MARK: - Test Configuration
    
    /// Standard timeout for network operations in integration tests
    let networkTimeout: TimeInterval = 30
    
    /// Extended timeout for long-running operations (document processing, etc.)
    let extendedTimeout: TimeInterval = 60

    var giniHealth: GiniHealth!
    var paymentService: PaymentService!
    
    /// Track created payment request IDs for cleanup
    var createdPaymentRequestIds: [String] = []
    
    /// Track created document IDs for cleanup
    var createdDocumentIds: [String] = []

    override func setUp() {
        super.setUp()

        giniHealth = GiniHealth(id: testClientID,
                                secret: testClientPassword,
                                domain: testClientDomain)

        paymentService = giniHealth.paymentService
        createdPaymentRequestIds = []
        createdDocumentIds = []
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
            for documentId in createdDocumentIds {
                print("ℹ️ Document cleanup skipped (would need Document object): \(documentId)")
                documentCleanupExpectation.fulfill()
            }
        }
        
        wait(for: [paymentCleanupExpectation, documentCleanupExpectation], timeout: networkTimeout)
        
        super.tearDown()
    }
}

