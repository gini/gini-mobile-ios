//
//  PaymentTests.swift
//  GiniHealthAPI-Unit-Tests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class PaymentTests: XCTestCase {
    
    let baseAPIURLString = "https://health-api.gini.net"
    let versionAPI = 4
    lazy var payService = PaymentService(sessionManager: SessionManagerMock(), apiDomain: .default, apiVersion: versionAPI)
    
    
    func testPaymentProvidersURL() {
        let resource = APIResource<[PaymentProvider]>(method: .paymentProviders,
                                                      apiDomain: .default,
                                                      apiVersion: versionAPI,
                                                      httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentProviders", "path should match")
    }
    
    func testPaymentProviderURL() {
        let resource = APIResource<PaymentProvider>(method: .paymentProvider(id: "7e72441c-32f8-11eb-b611-c3190574373c"),
                                                    apiDomain: .default,
                                                    apiVersion: versionAPI,
                                                    httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentProviders/7e72441c-32f8-11eb-b611-c3190574373c", "path should match")
    }
    
    func testPaymentRequestURL() {
        let resource = APIResource<PaymentRequest>(method: .paymentRequest(id: "7e72441c-32f8-11eb-b611-c3190574373c"),
                                                   apiDomain: .default,
                                                   apiVersion: versionAPI,
                                                   httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/7e72441c-32f8-11eb-b611-c3190574373c", "path should match")
    }
    
    func testPaymentRequestsURL() {
        let resource = APIResource<PaymentRequests>(method: .paymentRequests(limit: 20, offset: 0),
                                                    apiDomain: .default,
                                                    apiVersion: versionAPI,
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
                                           apiVersion: versionAPI,
                                           httpMethod: .post,
                                           body: jsonData)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests", "path should match")
    }
    
    func tesDeletePaymentRequestURL() {
        let mockRequestId = "mockRequestId"
        let resource = APIResource<String>(method: .deletePaymentRequest(id: mockRequestId),
                                           apiDomain: .default,
                                           apiVersion: versionAPI,
                                           httpMethod: .delete)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/\(mockRequestId)", "path should match")
    }
    
    func testPaymentProviders() {
        let sessionManagerMock = SessionManagerMock()
        sessionManagerMock.initializeWithPaymentProvidersResponse()
        
        payService.paymentProviders { result in
            switch result {
            case .success:
                XCTAssertEqual(sessionManagerMock.providersResponse.count, 11, "providers should not be empty")
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
    
    func testPaymentURL() {
        let resource = APIResource<Payment>(method: .payment(id: "d8b46793-31b4-49d5-8f81-554e9e13f3f5"),
                                            apiDomain: .default,
                                            apiVersion: versionAPI,
                                            httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/paymentRequests/d8b46793-31b4-49d5-8f81-554e9e13f3f5/payment", "path should match")
    }
}
