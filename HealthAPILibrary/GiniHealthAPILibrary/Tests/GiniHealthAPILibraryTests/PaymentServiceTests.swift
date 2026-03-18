//
//  PaymentServiceTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

class PaymentServiceTests: DocumentServiceTestBase {
    var paymentService: PaymentService!

    override func setUp() {
        super.setUp()
        paymentService = PaymentService(sessionManager: sessionManagerMock, apiVersion: 5)
    }

    // MARK: - Helper

    func testPaymentRequestCreation() {
        awaitSuccess(description: "returns payment request id") {
            self.paymentService.createPaymentRequest(sourceDocumentLocation: "",
                                                     paymentProvider: "b09ef70a-490f-11eb-952e-9bc6f4646c57",
                                                     recipient: "James Bond",
                                                     iban: "DE02300209000106531065",
                                                     bic: nil,
                                                     amount: "33.78:EUR",
                                                     purpose: "save the world",
                                                     completion: $0)
        } validate: { paymentRequestId in
            XCTAssertEqual(paymentRequestId, SessionManagerMock.paymentRequestId, "payment request ids should match")
        }
    }

    func testPaymentRequestDeletion() {
        awaitSuccess(description: "returns payment request id") {
            self.paymentService.deletePaymentRequest(id: SessionManagerMock.paymentRequestId, completion: $0)
        } validate: { paymentRequestId in
            XCTAssertEqual(paymentRequestId, SessionManagerMock.paymentRequestId, "payment request ids should match")
        }
    }
    
    func testPaymentProviders() throws {
        let expect = expectation(description: "returns array of payment providers")
        sessionManagerMock.initializeWithPaymentProvidersResponse()
        let paymentProvidersResponse: [PaymentProviderResponse] = try loadJSON(fromFile: "providers", type: "json")
        paymentService.paymentProviders { result in
            switch result {
            case .success(let providersResponse):
                XCTAssertEqual(providersResponse.count,
                               paymentProvidersResponse.count,
                               "providers count should match")
                expect.fulfill()
            case .failure(let error):
                XCTFail("Unexpected failure: \(error)")
            }
        }
        wait(for: [expect], timeout: 10)
    }

    func testPaymentProvidersConcurrency() {
        let expectation = XCTestExpectation(description: "Providers loaded")
        var results: [Result<PaymentProviders, GiniError>] = []

        // Call completion multiple times to detect double-call bug
        paymentService.paymentProviders { result in
            results.append(result)
            if results.count == 1 {
                expectation.fulfill()
            } else {
                XCTFail("Completion called \(results.count) times!")
            }
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(results.count, 1, "Completion should only be called once")
    }

    func testPaymentProvider() throws {
        let paymentProvider: PaymentProviderResponse = try loadJSON(fromFile: "provider", type: "json")
        awaitSuccess(description: "returns a payment provider via id") {
            self.paymentService.paymentProvider(id: SessionManagerMock.paymentProviderId, completion: $0)
        } validate: { provider in
            XCTAssertEqual(provider.id, paymentProvider.id, "provider ids should match")
        }
    }

    func testLoadPaymentRequest() {
        awaitSuccess(description: "returns an array of payment requests") {
            self.paymentService.paymentRequest(id: SessionManagerMock.paymentRequestId, completion: $0)
        } validate: { request in
            let requestId = String(request.links?.linksSelf.split(separator: "/").last ?? "")
            XCTAssertEqual(requestId, SessionManagerMock.paymentRequestId, "payment request ids should match")
        }
    }

    func testLoadPDFForPaymentRequest() {
        awaitSuccess(description: "returns PDF") {
            self.paymentService.pdfWithQRCode(paymentRequestId: SessionManagerMock.paymentRequestId, completion: $0)
        } validate: { data in
            XCTAssertNotNil(data)
        }
    }

    func testPayment() {
        awaitSuccess(description: "returns an array of payment requests") {
            self.paymentService.payment(id: "118edf41-102a-4b40-8753-df2f0634cb86", completion: $0)
        } validate: { payment in
            let requestId = String(payment.links?.paymentRequest?.split(separator: "/").last ?? "")
            XCTAssertEqual(requestId, SessionManagerMock.paymentID, "payment request ids should match")
        }
    }
}
