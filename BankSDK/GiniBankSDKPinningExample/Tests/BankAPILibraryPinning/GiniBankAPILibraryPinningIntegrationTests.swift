//
//  GiniBankAPILibraryPinningIntegrationTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import TrustKit

class GiniBankAPILibraryPinningIntegrationTests: XCTestCase {
    
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    let paymentRequestID = "a6466506-acf1-4896-94c8-9b398d4e0ee1"
    var giniBankAPILib: GiniBankAPI!
    var documentService: DefaultDocumentService!
    
    override func setUp() {
        let yourPublicPinningConfig = [
            kTSKPinnedDomains: [
                "pay-api.gini.net": [
                    kTSKPublicKeyHashes: [
                        // old *.gini.net public key
                        "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                        // new *.gini.net public key, active from around June 2020
                        "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
                    ]],
                "user.gini.net": [
                    kTSKPublicKeyHashes: [
                        // old *.gini.net public key
                        "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                        // new *.gini.net public key, active from around June 2020
                        "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
                    ]],
            ]] as [String: Any]
        let client = Client(id: clientId, secret: clientSecret, domain: "pay-api-lib-example")
        giniBankAPILib = GiniBankAPI.Builder(client: client, pinningConfig: yourPublicPinningConfig).build()
        documentService = giniBankAPILib.documentService()
    }
    
    func testErrorLogging() {
        let expect = expectation(description: "it logs the error event")

        let errorEvent = ErrorEvent(deviceModel: UIDevice.current.model,
                                    osName: UIDevice.current.systemName,
                                    osVersion: UIDevice.current.systemVersion,
                                    captureSdkVersion: "Not available",
                                    apiLibVersion: Bundle(for: GiniBankAPI.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                                    description: "Error logging integration test",
                                    documentId: nil,
                                    originalRequestId: nil)

        documentService.log(errorEvent: errorEvent) { result in
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
        let paymentService = giniBankAPILib.paymentService()
        XCTAssertEqual(paymentService.apiDomain.domainString, "pay-api.gini.net")
    }

    func testFetchPaymentRequest(){
        let expect = expectation(description: "it fetches the payment request")

        let paymentService = giniBankAPILib.paymentService()
        paymentService.paymentRequest(id: paymentRequestID) { result in
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

        let paymentService = giniBankAPILib.paymentService()
        paymentService.resolvePaymentRequest(id: paymentRequestID, 
                                             recipient: "Dr. med. Hackler",
                                             iban: "DE13760700120500154000",
                                             bic: "", amount: "335.50:EUR",
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

        let paymentService = giniBankAPILib.paymentService()
        paymentService.payment(id: "a6466506-acf1-4896-94c8-9b398d4e0ee1") { result in
            switch result {
            case .success(let payment):
                XCTAssertEqual(payment.iban, "DE13760700120500154000")
                expect.fulfill()
            case .failure(let error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }
}
