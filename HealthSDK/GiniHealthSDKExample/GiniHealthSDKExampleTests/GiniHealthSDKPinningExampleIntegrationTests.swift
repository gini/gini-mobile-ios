//
//  GiniHealthSDKPinningExampleIntegrationTests.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniHealthSDKExample

class GiniHealthSDKPinningExampleIntegrationTests: XCTestCase {
    
    // MARK: - Test Configuration
    
    /// Standard timeout for network operations
    private let networkTimeout: TimeInterval = 30
    
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
    
    override func setUp() {
        super.setUp()
        let client = Client(id: testClientID,
                            secret: testClientPassword,
                            domain: testClientDomain)
        giniHealthAPILib = GiniHealthAPI.Builder(client: client,
                                                 pinningConfig: yourPublicPinningConfig).build()
        sdk = GiniHealth(giniApiLib: giniHealthAPILib)
        paymentService = sdk.paymentService
    }
    
    
    func testBuildPaymentService() {
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
    func testCreatePaymentRequest() throws {
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
        paymentService.createPaymentRequest(sourceDocumentLocation: nil,
                                            paymentProvider: providerId,
                                            recipient: "Dr. med. Hackler",
                                            iban: "DE02300209000106531065",
                                            bic: "CMCIDEDDXXX",
                                            amount: "335.50:EUR",
                                            purpose: "ReNr AZ356789Z") { result in
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
