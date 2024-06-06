//
//  PaymentTests.swift
//  GiniHealthAPI-Unit-Tests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

class PaymentServiceTests: XCTestCase {
    var sessionManagerMock: SessionManagerMock!
    var defaultDocumentService: DefaultDocumentService!
    var paymentService: PaymentService!

    override func setUp() {
        sessionManagerMock = SessionManagerMock()
        defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock)
        paymentService = PaymentService(sessionManager: sessionManagerMock)
    }

    func testPaymentRequestCreation() {
        let expect = expectation(description: "returns payment request id")
        
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: "b09ef70a-490f-11eb-952e-9bc6f4646c57", recipient: "James Bond", iban: "DE02300209000106531065", bic: "", amount: "33.78:EUR", purpose: "save the world") { result in
            switch result {
            case .success(let paymentRequestId):
                XCTAssertEqual(paymentRequestId,
                               SessionManagerMock.paymentRequestId,
                               "payment request ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }
        wait(for: [expect], timeout: 1)
    }
    
    func testPaymentProviders() {
        let expect = expectation(description: "returns array of payment providers")
        sessionManagerMock.initializeWithPaymentProvidersResponse()
        let paymentProvidersResponse = loadProvidersResponse()
        paymentService.paymentProviders { result in
            switch result {
            case .success(let providersResponse):
                XCTAssertEqual(providersResponse.count,
                               paymentProvidersResponse.count,
                               "providers count should match")
                expect.fulfill()
            case .failure:
                break
            }
        }
        wait(for: [expect], timeout: 10)
    }
    
    func testPaymentProvider() {
        let expect = expectation(description: "returns a payment provider via id")
        let paymentProvider = loadProviderResponse()
        paymentService.paymentProvider(id: SessionManagerMock.paymentProviderId){ result in
            switch result {
            case .success(let provider):
                XCTAssertEqual(provider.id,
                               paymentProvider.id,
                               "provider ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }
        wait(for: [expect], timeout: 1)
    }

    func testLoadPaymentRequest() {
        let expect = expectation(description: "returns an array of payment requests")
        paymentService.paymentRequest(id:SessionManagerMock.paymentRequestId){ result in
            switch result {
            case .success(let request):
                let requestID = String(request.links?.linksSelf.split(separator: "/").last ?? "")
                XCTAssertEqual(requestID,
                               SessionManagerMock.paymentRequestId,
                               "payment request ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }
        wait(for: [expect], timeout: 1)
    }

    func testLoadPDFForPaymentRequest() {
        let expect = expectation(description: "returns PDF")
        paymentService.pdfWithQRCode(paymentRequestId: SessionManagerMock.paymentRequestId) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
                expect.fulfill()
            case .failure:
                break
            }
        }
        wait(for: [expect], timeout: 1)
    }
}
