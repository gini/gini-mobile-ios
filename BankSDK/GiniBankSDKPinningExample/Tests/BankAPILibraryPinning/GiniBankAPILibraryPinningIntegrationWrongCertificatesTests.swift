//
//  GiniBankAPILibraryPinningIntegrationTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import TrustKit

class PinningWrongCertificatesIntegrationTests: XCTestCase {
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    private let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    private let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    private let paymentRequestID = "a6466506-acf1-4896-94c8-9b398d4e0ee1"
    private var giniBankAPILib: GiniBankAPI!
    private var documentService: DefaultDocumentService!

    override func setUp() {
        let yourPublicPinningConfig = [
            kTSKPinnedDomains: [
                "pay-api.gini.net": [
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
        let client = Client(id: clientId, secret: clientSecret, domain: "pay-api-lib-example")
        giniBankAPILib = GiniBankAPI.Builder(client: client, pinningConfig: yourPublicPinningConfig).build()
        documentService = giniBankAPILib.documentService()
    }

    func testResolvePaymentRequestFails() {
        let expect = expectation(description: "it fails to resolve the payment request due to wrong pinning certificates")

        func handleFailure(error: GiniBankAPILibrary.GiniError, expectation: XCTestExpectation) {
            switch error {
            case .noResponse:
                XCTAssertTrue(true, "Expected SSL pinning failure")
            case .badRequest:
                XCTAssertTrue(true, "Received expected bad request error due to incorrect setup")
            default:
                XCTFail("Expected SSL pinning failure but got \(error)")
            }
            expectation.fulfill()
        }

        let paymentService = giniBankAPILib.paymentService()
        paymentService.resolvePaymentRequest(id: paymentRequestID,
                                             recipient: "Dr. med. Hackler",
                                             iban: "DE13760700120500154000",
                                             bic: "",
                                             amount: "335.50:EUR",
                                             purpose: "ReNr AZ356789Z") { result in
            switch result {
            case .success:
                XCTFail("Resolving the payment request should have failed due to wrong pinning certificates")
            case .failure(let error):
                handleFailure(error: error, expectation: expect)
            }
        }
        wait(for: [expect], timeout: 10)
    }
}
