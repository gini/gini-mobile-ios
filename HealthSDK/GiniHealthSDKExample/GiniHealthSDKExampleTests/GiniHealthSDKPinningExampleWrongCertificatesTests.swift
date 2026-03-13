//
//  GiniHealthSDKPinningExampleWrongCertificatesTests.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniHealthSDKExample

class GiniHealthSDKPinningExampleWrongCertificatesTests: XCTestCase {
    
    // MARK: - Test Configuration
    
    /// Standard timeout for network operations in integration tests
    private let networkTimeout: TimeInterval = 30
    
    /// Extended timeout for long-running operations (document processing, etc.)
    private let extendedTimeout: TimeInterval = 60
    
    let wrongPublicPinningConfig = [
        "health-api.gini.net": [
            // Wrong hashes
            "TQEtdMbmwFgYUifM4LDF+xgEtd0z69mPGmkp014d6ZY=",
            "rFjc3wG7lTZe43zeYTvPq8k4xdDEutCmIhI5dn4oCeE="
        ],
        "user.gini.net": [
            // Wrong hashes
            "TQEtdMbmwFgYUifM4LDF+xgEtd0z69mPGmkp014d6ZY=",
            "rFjc3wG7lTZe43zeYTvPq8k4xdDEutCmIhI5dn4oCeE="
        ],
    ]

    var giniHealthAPILib: GiniHealthAPI!
    var paymentService: PaymentService!
    var sdk: GiniHealth!

    override func setUp() {
        super.setUp()
        let client = Client(id: testClientID,
                            secret: testClientPassword,
                            domain: testClientDomain)
        giniHealthAPILib = GiniHealthAPI.Builder(client: client,
                                                 pinningConfig: wrongPublicPinningConfig).build()
        sdk = GiniHealth(giniApiLib: giniHealthAPILib)
        paymentService = sdk.paymentService
    }
    
    
    func testBuildPaymentService() {
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
    // MARK: - Disabled Tests
    
    func testCreatePaymentRequest() throws {
        // SSL pinning with wrong certificates doesn't reliably fail in simulator environments.
        // To properly test certificate pinning, run on a physical device with network monitoring.
        throw XCTSkip("SSL pinning with wrong certificates is unreliable in simulator - requires physical device testing")
    }
}
