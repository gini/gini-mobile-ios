//
//  GiniBankAPILibraryPinningIntegrationTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary
@testable import TrustKit
@testable import GiniUtilites

class GiniBankAPILibraryPinningIntegrationTests: XCTestCase {
    
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    private let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    private let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    // In cases tests are failing please check if the `paymentRequestID` is still valid
    private let paymentRequestID = "77deedc2-16c2-4597-9199-83451f43a360"
    private let validator = IBANValidator()

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
        paymentService.paymentRequest(id: paymentRequestID) { [weak self] result in
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

        let paymentService = giniBankAPILib.paymentService()
        paymentService.resolvePaymentRequest(id: paymentRequestID, 
                                             recipient: "Dr. med. Hackler",
                                             iban: "DE02300209000106531065",
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

    func testPayment() {
        let expect = expectation(description: "it gets the payment")

        let paymentService = giniBankAPILib.paymentService()
        paymentService.payment(id: paymentRequestID) { [weak self] result in
            switch result {
            case .success(let payment):
                self?.assertValidIBAN(payment.iban)
                expect.fulfill()
            case .failure(let error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }

    private func assertValidIBAN(_ iban: String) {
        XCTAssertFalse(iban.isEmpty, "IBAN should not be empty")
        XCTAssertTrue(validator.isValid(iban: iban), "IBAN should be valid")
    }
}
