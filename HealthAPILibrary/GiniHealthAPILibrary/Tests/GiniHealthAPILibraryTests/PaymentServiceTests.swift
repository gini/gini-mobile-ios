//
//  PaymentTests.swift
//  GiniHealthAPILib-Unit-Tests
//
//  Created by Nadya Karaban on 13.04.21.
//

import XCTest
@testable import GiniHealthAPILibrary

class PaymentServiceTests: XCTestCase {
        var sessionManagerMock: SessionManagerMock!
        var defaultDocumentService: DefaultDocumentService!
        var accountingDocumentService: AccountingDocumentService!
        var paymentService: PaymentService!

        override func setUp() {
            sessionManagerMock = SessionManagerMock()
            defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock)
            accountingDocumentService = AccountingDocumentService(sessionManager: sessionManagerMock)
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
        sessionManagerMock.initializeWithPaymentProviders()
        let paymentProviders = loadProviders()
        paymentService.paymentProviders { result in
            switch result {
            case .success(let providers):
                XCTAssertEqual(providers.count,
                               paymentProviders.count,
                               "providers count should match")
                expect.fulfill()
            case .failure:
                break
            }
      }
        wait(for: [expect], timeout: 1)
    }
    
    func testPaymentProvider() {
        let expect = expectation(description: "returns a payment provider via id")
        let paymentProvider = loadProvider()
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
    
    func testResolvePaymentRequest() {
        let expect = expectation(description: "returns resolved payment request id")

        paymentService.resolvePaymentRequest(id: "118edf41-102a-4b40-8753-df2f0634cb86", recipient: "Uno Flüchtlingshilfe", iban: "DE78370501980020008850", amount: "1.00:EUR", purpose: "ReNr 12345") { result in
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
                let requestID = String(payment.links?.paymentRequest?.split(separator: "/").last ?? "")
                XCTAssertEqual(requestID,
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


