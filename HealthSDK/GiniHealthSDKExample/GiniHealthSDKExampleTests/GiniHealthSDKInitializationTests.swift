//
//  GiniHealthSDKInitializationTests.swift
//  GiniHealthSDKExampleTests
//
//  SDK Initialization tests
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary

/// Tests for SDK initialization and basic configuration
final class GiniHealthSDKInitializationTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - SDK Initialization Tests

    func testSDKInitialization() throws {
        try skipIfCredentialsMissing()
        XCTAssertNotNil(giniHealth)
        XCTAssertNotNil(paymentService)
        XCTAssertNotNil(giniHealth.documentService)
        print("✅ SDK services initialized")
    }

    func testPaymentServiceDomain() throws {
        try skipIfCredentialsMissing()
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
        print("✅ Payment service domain: health-api.gini.net")
    }
}
