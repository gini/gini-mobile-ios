//
//  BankAPILibraryIntegrationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
@testable import GiniBankAPILibrary

class BankAPILibraryIntegrationTests: BaseIntegrationTest {
    private let paymentRequestID = "a6466506-acf1-4896-94c8-9b398d4e0ee1"

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

    func testFetchPaymentRequest(){
        let expect = expectation(description: "it fetches the payment request")

        giniHelper.paymentService.paymentRequest(id: paymentRequestID) { result in
            switch result {
                case .success(let request):
                    XCTAssertEqual(request.iban, "DE13760700120500154000")
                    expect.fulfill()
                case .failure(let error):
                    XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }

    func testResolvePaymentRequest(){
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

    func testPayment(){
        let expect = expectation(description: "it gets the payment")

        giniHelper.paymentService.payment(id: "a6466506-acf1-4896-94c8-9b398d4e0ee1") { result in
            switch result {
                case .success(let payment):
                    XCTAssertEqual(payment.iban, "DE13760700120500154000")
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
}

