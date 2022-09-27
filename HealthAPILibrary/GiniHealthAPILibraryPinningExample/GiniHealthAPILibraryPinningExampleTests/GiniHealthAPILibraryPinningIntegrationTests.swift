//
//  GiniHealthAPILibraryPinningIntegrationTests.swift
//  GiniHealthAPILibraryPinningExampleTests
//
//  Created by Nadya Karaban on 17.05.22.
//

import XCTest
@testable import GiniHealthAPILibraryPinning
@testable import GiniHealthAPILibrary
@testable import TrustKit

class GiniHealthAPILibraryPinningIntegrationTests: XCTestCase {
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    let paymentRequestID = "a6466506-acf1-4896-94c8-9b398d4e0ee1"
    var giniHealthAPILib: GiniHealthAPI!
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
        let client = Client(id: clientId, secret: clientSecret, domain: "health-api.gini.net")
        giniHealthAPILib = GiniHealthAPI.Builder(client: client, pinningConfig: yourPublicPinningConfig).build()
        documentService = giniHealthAPILib.documentService()
    }

    func testBuildPaymentService() {
        let paymentService = giniHealthAPILib.paymentService()
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }

    func testFetchPaymentProviders() {
        let expect = expectation(description: "it fetches the payment providers")

        let paymentService = giniHealthAPILib.paymentService()
        paymentService.paymentProviders { result in
            switch result {
            case let .success(providers):
                XCTAssertEqual(providers.count, 11)
                expect.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }

    func testFetchPaymentProvider() {
        let expect = expectation(description: "it fetches the payment providers")

        let paymentService = giniHealthAPILib.paymentService()
        paymentService.paymentProvider(id: "b09ef70a-490f-11eb-952e-9bc6f4646c57") { result in
            switch result {
            case let .success(provider):
                XCTAssertEqual(provider.name, "Gini-Test-Payment-Provider")
                expect.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }

    func testFetchPaymentRequest() {
        let expect = expectation(description: "it fetches the payment request")

        let paymentService = giniHealthAPILib.paymentService()
        paymentService.paymentRequest(id: paymentRequestID) { result in
            switch result {
            case let .success(request):
                XCTAssertEqual(request.iban, "DE13760700120500154000")
                expect.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }

    func testCreatePayment() {
        let expect = expectation(description: "it creates a payment request")

        let paymentService = giniHealthAPILib.paymentService()
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: "dbe3a2ca-c9df-11eb-a1d8-a7efff6e88b7", recipient: "Dr. med. Hackler", iban: "DE02300209000106531065", bic: "CMCIDEDDXXX", amount: "335.50:EUR", purpose: "ReNr AZ356789Z") { result in
            switch result {
            case .success:
                expect.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }
}
