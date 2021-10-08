//
//  PaymentTests.swift
//  GiniHealthAPILib-Unit-Tests
//
//  Created by Nadya Karaban on 15.03.21.
//

import XCTest
@testable import GiniHealthAPILibrary

final class PaymentTests: XCTestCase {
    
    let baseAPIURLString = "https://pay-api.gini.net"
    var payService = PaymentService(sessionManager: SessionManagerMock(), apiDomain: .default)
    
    
    func testPaymentProvidersURL() {
        let resource = APIResource<[PaymentProvider]>(method: .paymentProviders,
                                               apiDomain: .default,
                                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentProviders", "path should match")
    }
    
    func testPaymentProviderURL() {
        let resource = APIResource<PaymentProvider>(method: .paymentProvider(id: "7e72441c-32f8-11eb-b611-c3190574373c"),
                                               apiDomain: .default,
                                               httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentProviders/7e72441c-32f8-11eb-b611-c3190574373c", "path should match")
    }
    
    func testPaymentRequestURL() {
        let resource = APIResource<PaymentRequest>(method: .paymentRequest(id: "7e72441c-32f8-11eb-b611-c3190574373c"),
                                               apiDomain: .default,
                                               httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/7e72441c-32f8-11eb-b611-c3190574373c", "path should match")
    }
    
    func testPaymentRequestsURL() {
        let resource = APIResource<PaymentRequests>(method: .paymentRequests(limit: 20, offset: 0),
                                               apiDomain: .default,
                                               httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests"+"?offset=0&limit=20", "path should match")
    }
    
    func testCreatePaymentRequestURL() {
        let paymentRequestBody = PaymentRequestBody(sourceDocumentLocation: "", paymentProvider: "b09ef70a-490f-11eb-952e-9bc6f4646c57", recipient: "James Bond", iban: "DE89370400440532013000", bic: "INGDDEFF123", amount: "33.78:EUR", purpose: "Save the world")
        guard let jsonData = try? JSONEncoder().encode(paymentRequestBody)
        else {
            assertionFailure("The PaymentRequestBody cannot be encoded")
            return
        }
        let resource = APIResource<String>(method: .createPaymentRequest,
                                                          apiDomain: .default,
                                                          httpMethod: .post,
                                                          body: jsonData)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests", "path should match")
    }
    
    func testResolvePaymentRequestURL() {
        let resolvingPaymentRequestBody = ResolvingPaymentRequestBody(recipient: "James Bond", iban: "DE89370400440532013000", bic: "INGDDEFF123", amount: "33.78:EUR", purpose: "Save the world")
        guard let jsonData = try? JSONEncoder().encode(resolvingPaymentRequestBody)
        else {
            assertionFailure("The PaymentRequestBody cannot be encoded")
            return
        }
        let resource = APIResource<String>(method: .resolvePaymentRequest(id: "d8b46793-31b4-49d5-8f81-554e9e13f3f5"),
                                               apiDomain: .default,
                                               httpMethod: .post,
                                               body: jsonData)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/d8b46793-31b4-49d5-8f81-554e9e13f3f5/payment", "path should match")
    }
    
    func testPaymentURL() {
        let resource = APIResource<Payment>(method: .payment(id: "d8b46793-31b4-49d5-8f81-554e9e13f3f5"),
                                               apiDomain: .default,
                                               httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/d8b46793-31b4-49d5-8f81-554e9e13f3f5/payment", "path should match")
    }
    
    func testPaymentProviders() {
        let sessionManagerMock = SessionManagerMock()
        sessionManagerMock.initializeWithPaymentProviders()
        
        payService.paymentProviders { result in
            switch result {
            case .success:
                XCTAssertEqual(sessionManagerMock.providers.count, 2, "providers should not be empty")
            case .failure:
                break
            }
        }
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
