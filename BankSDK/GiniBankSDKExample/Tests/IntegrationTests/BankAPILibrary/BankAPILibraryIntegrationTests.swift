//
//  BankAPILibraryIntegrationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary
@testable import GiniUtilites

class BankAPILibraryIntegrationTests: BaseIntegrationTest {
    // In cases tests are failing please check if the `paymentRequestID` is still valid
    private let paymentRequestID = "77deedc2-16c2-4597-9199-83451f43a360"
    private let validator = IBANValidator()
    func testErrorLogging() {
        let expect = expectation(description: "it logs the error event")

        let errorEvent = createErrorEvent(description: "Error logging integration test")

        giniHelper.giniBankAPIDocumentService.log(errorEvent: errorEvent) { result in
            switch result {
                case .success:
                    expect.fulfill()
                case .failure(let error):
                    XCTFail(String(describing: error))
            }
        }

        wait(for: [expect], timeout: 10)
    }

    func testBuildPaymentService() {
        XCTAssertEqual(giniHelper.paymentService.apiDomain.domainString, "pay-api.gini.net")
    }

    func testFetchPaymentRequest() {
        let expect = expectation(description: "it fetches the payment request")

        giniHelper.paymentService.paymentRequest(id: paymentRequestID) { [weak self] result in
            switch result {
                case .success(let request):
                    self?.assertValidIBAN(request.iban)
                    expect.fulfill()
                case .failure(let error):
                    XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }

    func testResolvePaymentRequest() {
        let message = "You can't resolve the previously resolved payment request"
        let expect = expectation(description: message)

        giniHelper.paymentService.resolvePaymentRequest(id: paymentRequestID, 
                                                        recipient: "Dr. med. Hackler",
                                                        iban: "DE13760700120500154000",
                                                        bic: "",
                                                        amount: "335.50:EUR",
                                                        purpose: "ReNr AZ356789Z") { result in
            switch result {
                case .success(_):
                    XCTFail(message)
                case .failure(_):
                    expect.fulfill()
            }
        }
        wait(for: [expect], timeout: 10)
    }

    func testPayment() {
        let expect = expectation(description: "it gets the payment")

        giniHelper.paymentService.payment(id: paymentRequestID) { [weak self] result in
            switch result {
                case .success(let payment):
                    self?.assertValidIBAN(payment.iban)
                    expect.fulfill()
                case .failure(let error):
                    XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 30)
    }

    private func createErrorEvent(description: String) -> ErrorEvent {
        return ErrorEvent(
            deviceModel: UIDevice.current.model,
            osName: UIDevice.current.systemName,
            osVersion: UIDevice.current.systemVersion,
            captureSdkVersion: "Not available",
            apiLibVersion: Bundle(for: GiniBankAPI.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            description: description,
            documentId: nil,
            originalRequestId: nil
        )
    }

    private func assertValidIBAN(_ iban: String) {
        XCTAssertFalse(iban.isEmpty, "IBAN should not be empty")
        XCTAssertTrue(validator.isValid(iban: iban), "IBAN should be valid")
    }
}

