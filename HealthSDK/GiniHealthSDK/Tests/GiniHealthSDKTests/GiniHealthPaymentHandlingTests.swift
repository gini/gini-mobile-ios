//
//  GiniHealthPaymentHandlingTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import XCTest

@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthPaymentHandlingTests: XCTestCase {
    
    var giniHealthAPI: GiniHealthAPI!
    var giniHealth: GiniHealth!
    private let versionAPI = 4

    
    override func setUp() {
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        let clientConfigurationService = ClientConfigurationService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        GiniHealthConfiguration.shared.clientConfiguration = nil
        giniHealthAPI = GiniHealthAPI(documentService: documentService,
                                      paymentService: paymentService,
                                      clientConfigurationService: clientConfigurationService)
        giniHealth = GiniHealth(giniApiLib: giniHealthAPI)
    }
    
    override func tearDown() {
        giniHealthAPI = nil
        giniHealth = nil
        super.tearDown()
    }
    
    func testCreatePaymentRequestSuccess() {
        // Given
        let expectedPaymentRequestID = MockSessionManager.paymentRequestId

        // When
        let expectation = self.expectation(description: "Creating payment request")
        var receivedRequestId: String?
        let paymentInfo = GiniHealthSDK.PaymentInfo(recipient: "Uno Flüchtlingshilfe", iban: "DE78370501980020008850", bic: "COLSDE33", amount: "1.00:EUR", purpose: "ReNr 12345", paymentUniversalLink: "ginipay-test://paymentRequester", paymentProviderId: "b09ef70a-490f-11eb-952e-9bc6f4646c57")
        giniHealth.createPaymentRequest(paymentInfo: PaymentInfo(paymentComponentsInfo: paymentInfo), completion: { result in
            switch result {
            case .success(let requestId):
                receivedRequestId = requestId
            case .failure(_):
                receivedRequestId = nil
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedRequestId)
        XCTAssertEqual(receivedRequestId, expectedPaymentRequestID)
    }
    
    func testDeletePaymentRequestSuccess() {
        // Given
        let expectedPaymentRequestID = MockSessionManager.paymentRequestId

        // When
        let expectation = self.expectation(description: "Deleting payment request")
        var receivedRequestId: String?
        
        giniHealth.deletePaymentRequest(id: expectedPaymentRequestID, completion: { result in
            switch result {
            case .success(let requestId):
                receivedRequestId = requestId
            case .failure(_):
                receivedRequestId = nil
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedRequestId)
        XCTAssertEqual(receivedRequestId, expectedPaymentRequestID)
    }
    
    func testFetchPaymentRequestWithExpirationDate() {
        // Given
        let expectedExpirationDate = "2020-12-08T15:50:23"

        // When
        let expectation = self.expectation(description: "Getting payment request with expiration date")
        var receivedPaymentRequest: PaymentRequest?

        giniHealth.paymentService.paymentRequest(id: MockSessionManager.paymentRequestIdWithExpirationDate) { result in
            switch result {
            case .success(let paymentRequest):
                receivedPaymentRequest = paymentRequest
            case .failure(_):
                receivedPaymentRequest = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedPaymentRequest)
        XCTAssertEqual(receivedPaymentRequest?.expirationDate, expectedExpirationDate)
    }

    func testFetchPaymentRequestWithMissingExpirationDate() {
        // When
        let expectation = self.expectation(description: "Getting payment request without expiration date")
        var receivedPaymentRequest: PaymentRequest?

        giniHealth.paymentService.paymentRequest(id: MockSessionManager.paymentRequestIdWithMissingExpirationDate) { result in
            switch result {
            case .success(let paymentRequest):
                receivedPaymentRequest = paymentRequest
            case .failure(_):
                receivedPaymentRequest = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedPaymentRequest)
        XCTAssertNil(receivedPaymentRequest?.expirationDate)
    }
}
