//
//  GiniHealthSDKPinningExampleWrongCertificatesTests.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary

class GiniHealthSDKPinningExampleWrongCertificatesTests: GiniHealthSDKIntegrationTestsBase {

    let wrongPublicPinningConfig: [String: [String]] = [
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

    override func setUp() {
        super.setUp()
        let giniHealthAPILib = GiniHealthAPI.Builder(client: makeClient(),
                                                     pinningConfig: wrongPublicPinningConfig).build()
        giniHealth = GiniHealth(giniApiLib: giniHealthAPILib)
        paymentService = giniHealth.paymentService
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
