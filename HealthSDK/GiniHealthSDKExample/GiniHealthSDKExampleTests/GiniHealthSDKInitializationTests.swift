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

/**
 Tests for SDK initialization and basic configuration
 */
final class GiniHealthSDKInitializationTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - SDK Initialization Tests

    func testSDKInitialization() throws {
        XCTAssertNotNil(giniHealth)
        XCTAssertNotNil(paymentService)
        XCTAssertNotNil(giniHealth.documentService)
    }

    func testPaymentServiceDomain() throws {
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }

    // MARK: - Initializer Coverage

    func testInitWithCredentialsSetsUpPaymentComponentsController() {
        // When
        let instance = GiniHealth(id: testClientID,
                                  secret: testClientPassword,
                                  domain: testClientDomain)

        // Then
        XCTAssertNotNil(instance.paymentComponentsController,
                        "paymentComponentsController should be initialised by the credential init")
    }

    func testInitWithPinningConfigSetsUpPaymentComponentsController() {
        // When
        let instance = GiniHealth(id: testClientID,
                                  secret: testClientPassword,
                                  domain: testClientDomain,
                                  pinningConfig: [:])

        // Then
        XCTAssertNotNil(instance.paymentComponentsController,
                        "paymentComponentsController should be initialised by the pinning-config init")
    }
}
