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
        let documentLink = "https://health-api.gini.net/documents/f4f77c2f-2d8b-4eb2-abbe-daa8b2b9c657"
        let fileName = "wish_receipt_extractions"
        let expectedExtractionContainer: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniHealthSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []
        let documentFileName = "wish_receipt"

        guard let healthDocument: GiniHealthAPILibrary.Document = GiniHealthSDKTests.load(fromFile: documentFileName) else {
            XCTFail("Cannot load file `\(documentFileName).json")
            return
        }
        
        let expectedDocument: GiniHealthSDK.Document? = GiniHealthSDK.Document(healthDocument: healthDocument)

        guard let expectedDocument else {
            XCTFail("Error loading file: `\(documentFileName).json`")
            return
        }
        let expectedDataForReview = DataForReview(document: expectedDocument, extractions: expectedExtractions)
        let expectedDocumentLink = expectedDocument.links.document.absoluteString
        let extractions = expectedDataForReview.extractions

        // When
        let expectation = self.expectation(description: "Creating payment request")
        var receivedRequestId: String?
        let paymentInfo = PaymentInfo(sourceDocumentLocation: expectedDocumentLink,
            recipient: extractions.first(where: {$0.name == "payment_recipient"})?.value ?? "",
                                                    iban: extractions.first(where: {$0.name == "iban"})?.value.uppercased() ?? "",
                                                    amount: extractions.first(where: {$0.name == "amount_to_pay"})?.value ?? "",
                                                    purpose: extractions.first(where: {$0.name == "payment_purpose"})?.value ?? "",
                                                    paymentUniversalLink: "ginipay-test://paymentRequester",
                                                    paymentProviderId: "b09ef70a-490f-11eb-952e-9bc6f4646c57")
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo, completion: { result in
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
        XCTAssertNotNil(expectedDocumentLink)
        XCTAssertNotNil(receivedRequestId)
        XCTAssertEqual(receivedRequestId, expectedPaymentRequestID)
        XCTAssertEqual(documentLink, expectedDocumentLink)
    }
    
    func testCreatePaymentRequestSuccessWithDocument() {
        // Given
        let expectedPaymentRequestID = MockSessionManager.paymentRequestId
        
        // When
        let expectation = self.expectation(description: "Creating payment request")
        var receivedRequestId: String?
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(sourceDocumentLocation: "https://health-api.gini.net/documents/bb385cf9-21b7-4990-93f7-4cfcfa626436",
                                                             recipient: "Uno Flüchtlingshilfe",
                                                             iban: "DE78370501980020008850",
                                                             bic: "COLSDE33",
                                                             amount: "1.00:EUR",
                                                             purpose: "ReNr 12345",
                                                             paymentUniversalLink: "ginipay-test://paymentRequester",
                                                             paymentProviderId: "b09ef70a-490f-11eb-952e-9bc6f4646c57")
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo, completion: { result in
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
    
    func testGettingPaymentSuccess() {
        // Given
        let expectedIBAN = "DE02300209000106531065"
        
        // When
        let expectation = self.expectation(description: "Getting payment for a given payment request")
        var receivedPayment: Payment?

        giniHealth.getPayment(id: MockSessionManager.paymentRequestId) { result in
            switch result {
            case .success(let payment):
                receivedPayment = payment
            case .failure(_):
                receivedPayment = nil
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedPayment)
        XCTAssertEqual(receivedPayment?.iban, expectedIBAN)
    }
}
