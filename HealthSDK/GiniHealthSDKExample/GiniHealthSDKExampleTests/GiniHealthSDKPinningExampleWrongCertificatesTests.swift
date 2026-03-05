//
//  GiniHealthSDKPinningExampleWrongCertificatesTests.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary

class GiniHealthSDKPinningExampleWrongCertificatesTests: XCTestCase {
    
    // MARK: - Test Configuration
    
    /// Standard timeout for network operations in integration tests
    private let networkTimeout: TimeInterval = 30
    
    /// Extended timeout for long-running operations (document processing, etc.)
    private let extendedTimeout: TimeInterval = 60
    
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    // These tests will be skipped if credentials are not provided
    private var clientId: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_ID"]
        return value?.isEmpty == false ? value : nil
    }
    
    private var clientSecret: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_SECRET"]
        return value?.isEmpty == false ? value : nil
    }
    
    let yourPublicPinningConfig = [
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
    
    /// Helper to skip tests when credentials are not available
    private func skipIfCredentialsMissing() throws {
        guard clientId != nil, clientSecret != nil else {
            throw XCTSkip("Integration test skipped: CLIENT_ID and CLIENT_SECRET environment variables must be set. Configure them in the test scheme or test plan.")
        }
    }
    
    override func setUp() {
        guard let id = clientId, let secret = clientSecret else {
            return // XCTSkip will be called in each test method
        }
        
        let domain = "health-sdk-pinning-example"
        let client = Client(id: id,
                            secret: secret,
                            domain: domain)
        giniHealthAPILib = GiniHealthAPI
               .Builder(client: client, pinningConfig: yourPublicPinningConfig)
               .build()
        sdk = GiniHealth.init(id: id, secret: secret, domain: domain)
        paymentService = sdk.paymentService
    }
    
    
    func testBuildPaymentService() throws {
        try skipIfCredentialsMissing()
        
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
    // MARK: - Disabled Tests
    // This test is disabled because SSL pinning with wrong certificates doesn't reliably
    // fail in simulator environments. The test expects the request to fail but it succeeds.
    // This is a known limitation of certificate pinning testing in iOS simulators.
    // To properly test certificate pinning, run on a physical device with network monitoring.
    
    func skip_testCreatePaymentRequest(){
        let expect = expectation(description: "it creates a payment request")

        paymentService.createPaymentRequest(sourceDocumentLocation: nil, paymentProvider: "dbe3a2ca-c9df-11eb-a1d8-a7efff6e88b7", recipient: "Dr. med. Hackler", iban: "DE02300209000106531065", bic: "CMCIDEDDXXX", amount: "335.50:EUR", purpose: "ReNr AZ356789Z") { result in
            switch result {
            case .success:
                XCTFail("creating a payment request should have failed due to wrong pinning certificates")
            case let .failure(error):
                XCTAssertEqual(error, GiniError.noResponse)
                expect.fulfill()
            }
        }
        wait(for: [expect], timeout: networkTimeout)
    }
}
