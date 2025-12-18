//
//  PaymentTests.swift
//  GiniBankAPI-Unit-Tests
//
//  Copyright © 2021 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class PaymentTests: XCTestCase {
    
    let baseAPIURLString = "https://pay-api.gini.net"
    var payService = PaymentService(sessionManager: SessionManagerMock(), apiDomain: .default)
    
    func testPaymentRequestURL() {
        let resource = APIResource<PaymentRequest>(method: .paymentRequest(id: "7e72441c-32f8-11eb-b611-c3190574373c"),
                                                   apiDomain: .default,
                                                   httpMethod: .get)
        let urlString = resource.url?.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/7e72441c-32f8-11eb-b611-c3190574373c",
                       "path should match")
    }
    
    func testPaymentRequestsURL() {
        let resource = APIResource<PaymentRequests>(method: .paymentRequests(limit: 20, offset: 0),
                                                    apiDomain: .default,
                                                    httpMethod: .get)
        let urlString = resource.url?.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests"+"?offset=0&limit=20",
                       "path should match")
    }
    
    func testResolvePaymentRequestURL() {
        let resolvingPaymentRequestBody = ResolvingPaymentRequestBody(recipient: "James Bond",
                                                                      iban: "DE89370400440532013000",
                                                                      bic: "INGDDEFF123",
                                                                      amount: "33.78:EUR",
                                                                      purpose: "Save the world")
        guard let jsonData = try? JSONEncoder().encode(resolvingPaymentRequestBody)
        else {
            assertionFailure("The PaymentRequestBody cannot be encoded")
            return
        }
        let resource = APIResource<String>(method: .resolvePaymentRequest(id: "d8b46793-31b4-49d5-8f81-554e9e13f3f5"),
                                           apiDomain: .default,
                                           httpMethod: .post,
                                           body: jsonData)
        let urlString = resource.url?.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/d8b46793-31b4-49d5-8f81-554e9e13f3f5/payment",
                       "path should match")
    }
    
    func testPaymentURL() {
        let resource = APIResource<Payment>(method: .payment(id: "d8b46793-31b4-49d5-8f81-554e9e13f3f5"),
                                            apiDomain: .default,
                                            httpMethod: .get)
        let urlString = resource.url?.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/d8b46793-31b4-49d5-8f81-554e9e13f3f5/payment",
                       "path should match")
    }
    
    func testPaymentRequests() {
        let sessionManagerMock = SessionManagerMock()
        sessionManagerMock.initializeWithPaymentRequests()
        
        payService.paymentRequests(limit: 20, offset: 0) { result in
            switch result {
            case .success:
                XCTAssertEqual(sessionManagerMock.paymentRequests.count, 2, "payment requests should not be empty")
            case .failure:
                break
            }
        }
    }
}
