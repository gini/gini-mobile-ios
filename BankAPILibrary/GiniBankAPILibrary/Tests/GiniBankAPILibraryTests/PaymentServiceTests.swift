//
//  PaymentTests.swift
//  GiniBankAPI-Unit-Tests
//
//  Created by Nadya Karaban on 13.04.21.
//

import XCTest
@testable import GiniBankAPILibrary

class PaymentServiceTests: XCTestCase {
        var sessionManagerMock: SessionManagerMock!
        var defaultDocumentService: DefaultDocumentService!
        var paymentService: PaymentService!

        override func setUp() {
            sessionManagerMock = SessionManagerMock()
            defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock)
            paymentService = PaymentService(sessionManager: sessionManagerMock)
        }

    func testLoadPaymentRequest() {
        let expect = expectation(description: "returns an array of payment requests")
        paymentService.paymentRequest(id:SessionManagerMock.paymentRequestId){ result in
            switch result {
            case .success(let request):
                let requestId = String(request.links?.linksSelf?.split(separator: "/").last ?? "")
                XCTAssertEqual(requestId,
                               SessionManagerMock.paymentRequestId,
                               "payment request ids should match")
                expect.fulfill()
            case .failure:
                break
            }
      }
        wait(for: [expect], timeout: 1)
    }
    
    func testResolvePaymentRequest() {
        let expect = expectation(description: "returns resolved payment request id")

        paymentService.resolvePaymentRequest(id: "118edf41-102a-4b40-8753-df2f0634cb86",
                                             recipient: "Uno Flüchtlingshilfe",
                                             iban: "DE78370501980020008850",
                                             amount: "1.00:EUR",
                                             purpose: "ReNr 12345") { result in
            switch result {
            case .success(let paymentRequest):
                XCTAssertEqual(paymentRequest.requesterUri,
                                   SessionManagerMock.paymentRequesterUri,
                                   "payment request urls should match")
                    expect.fulfill()
                
            case .failure:
                break
            }
        }
        wait(for: [expect], timeout: 1)
    }
    
    func testPayment() {
        let expect = expectation(description: "returns an array of payment requests")
        paymentService.payment(id: "118edf41-102a-4b40-8753-df2f0634cb86"){ result in
            switch result {
            case .success(let payment):
                let requestId = String(payment.links?.paymentRequest?.split(separator: "/").last ?? "")
                XCTAssertEqual(requestId,
                               SessionManagerMock.paymentID,
                               "payment request ids should match")
                expect.fulfill()
            case .failure:
                break
            }
      }
        wait(for: [expect], timeout: 1)
    }
}


