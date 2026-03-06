//
//  GiniHealthSDKPinningExampleIntegrationTests.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary

class GiniHealthSDKPinningExampleIntegrationTests: XCTestCase {
    
    // MARK: - Test Configuration
    
    /// Standard timeout for network operations
    private let networkTimeout: TimeInterval = 30
    
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
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
        ],
        "user.gini.net": [
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
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
    
    
    func testBuildPaymentService() {
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
    func testCreatePaymentRequest() throws {
        try skipIfCredentialsMissing()
        
        let expectProviders = expectation(description: "fetch payment providers")
        let expectRequest = expectation(description: "create payment request")
        
        var paymentProviderId: String?
        
        // First fetch actual payment providers
        paymentService.paymentProviders { result in
            switch result {
            case .success(let providers):
                paymentProviderId = providers.first?.id
                print("✅ Fetched \(providers.count) providers, using: \(paymentProviderId ?? "none")")
            case .failure(let error):
                XCTFail("Failed to fetch payment providers: \(error)")
            }
            expectProviders.fulfill()
        }
        
        wait(for: [expectProviders], timeout: networkTimeout)
        
        guard let providerId = paymentProviderId else {
            XCTFail("No payment provider available")
            return
        }
        
        // Now create payment request with real provider ID
        paymentService.createPaymentRequest(
            sourceDocumentLocation: nil,
            paymentProvider: providerId,
            recipient: "Dr. med. Hackler",
            iban: "DE02300209000106531065",
            bic: "CMCIDEDDXXX",
            amount: "335.50:EUR",
            purpose: "ReNr AZ356789Z"
        ) { result in
            switch result {
            case .success(let requestId):
                print("✅ Created payment request: \(requestId)")
                expectRequest.fulfill()
            case let .failure(error):
                XCTFail("Failed to create payment request: \(error.customError?.message ?? error.localizedDescription)")
            }
        }
        wait(for: [expectRequest], timeout: networkTimeout)
    }
}
