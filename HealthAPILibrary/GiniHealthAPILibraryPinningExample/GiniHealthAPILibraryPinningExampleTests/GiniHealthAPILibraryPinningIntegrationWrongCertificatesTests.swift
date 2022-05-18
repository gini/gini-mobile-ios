//
//  GiniHealthAPILibraryPinningIntegrationWrongCertificatesTests.swift
//  GiniHealthAPILibraryPinningExampleTests
//
//  Created by Nadya Karaban on 18.05.22.
//

import XCTest
@testable import GiniHealthAPILibraryPinning
@testable import GiniHealthAPILibrary
@testable import TrustKit

class HealthAPILibraryPinningWrongCertificatesTests: XCTestCase {

    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    var giniHealthAPILib: GiniHealthAPI!

    override func setUp() {
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
        let client = Client(id: clientId, secret: clientSecret, domain: "health-api.gini.net")
        giniHealthAPILib = GiniHealthAPI.Builder(client: client, pinningConfig: yourPublicPinningConfig).build()
    }
        
    func testСreatePaymentRequestFails() {
        let expect = expectation(description: "it fails to create a payment request due to wrong pinning certificates")

        let paymentService = giniHealthAPILib.paymentService()
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: "dbe3a2ca-c9df-11eb-a1d8-a7efff6e88b7", recipient: "Dr. med. Hackler", iban: "DE02300209000106531065", bic: "CMCIDEDDXXX", amount: "335.50:EUR", purpose: "ReNr AZ356789Z") { result in
            switch result {
            case .success:
                XCTFail("creating a payment request should have failed due to wrong pinning certificates")
            case let .failure(error):
                XCTAssertEqual(error, GiniHealthAPILibrary.GiniError.noResponse)
                expect.fulfill()
            }
        }
        wait(for: [expect], timeout: 10)
    }

}
