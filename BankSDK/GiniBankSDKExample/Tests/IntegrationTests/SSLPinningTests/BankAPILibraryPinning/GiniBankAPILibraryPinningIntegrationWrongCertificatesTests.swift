//
//  GiniBankAPILibraryPinningIntegrationTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

class PinningWrongCertificatesIntegrationTests: BaseIntegrationTest {

    override func setUp() {
        giniHelper.setupWithWrongPinningCertificates()
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

        giniHelper.paymentService?.resolvePaymentRequest(id: giniHelper.paymentRequestID,
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
