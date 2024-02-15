//
//  GiniHealthSDKPinningExampleWrongCertificatesTests.swift
//  GiniHealthSDKPinningExampleTests
//
//  Created by Nadya Karaban on 18.05.22.
//

import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniHealthAPILibraryPinning
@testable import GiniHealthSDKPinning
@testable import TrustKit

class GiniHealthSDKPinningExampleWrongCertificatesTests: XCTestCase {
    
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    let yourPublicPinningConfig = [
        kTSKPinnedDomains: [
            "health-api.gini.net": [
                kTSKPublicKeyHashes: [
                    // Wrong hashes
                    "TQEtdMbmwFgYUifM4LDF+xgEtd0z69mPGmkp014d6ZY=",
                    "rFjc3wG7lTZe43zeYTvPq8k4xdDEutCmIhI5dn4oCeE="
                ]],
            "user.gini.net": [
                kTSKPublicKeyHashes: [
                    // Wrong hashes
                    "TQEtdMbmwFgYUifM4LDF+xgEtd0z69mPGmkp014d6ZY=",
                    "rFjc3wG7lTZe43zeYTvPq8k4xdDEutCmIhI5dn4oCeE="
                ]],
        ]] as [String: Any]

    var giniHealthAPILib: GiniHealthAPI!
    var paymentService: PaymentService!
    var sdk: GiniHealth!
    
    override func setUp() {
        let client = Client(id: clientId,
                            secret: clientSecret,
                            domain: "health-sdk-pinning-example")
        giniHealthAPILib = GiniHealthAPI
               .Builder(client: client, pinningConfig: yourPublicPinningConfig)
               .build()
        sdk = GiniHealth.init(with: giniHealthAPILib)
        paymentService = sdk.paymentService
    }
    
    
    func testBuildPaymentService() {
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
    func testCreatePaymentRequest(){
        let expect = expectation(description: "it creates a payment request")

        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: "dbe3a2ca-c9df-11eb-a1d8-a7efff6e88b7", recipient: "Dr. med. Hackler", iban: "DE02300209000106531065", bic: "CMCIDEDDXXX", amount: "335.50:EUR", purpose: "ReNr AZ356789Z") { result in
            switch result {
            case .success:
                XCTFail("creating a payment request should have failed due to wrong pinning certificates")
            case let .failure(error):
                XCTAssertEqual(error, GiniError.unknown())
                expect.fulfill()
            }
        }
        wait(for: [expect], timeout: 10)
    }
}
