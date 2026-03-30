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

final class GiniHealthPaymentHandlingTests: GiniHealthTestCase {

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
        let expectedDataForReview = DataForReview(document: expectedDocument,
                                                  extractions: expectedExtractions)
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
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo,
                                        completion: { result in
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
        XCTAssertNotNil(expectedDocumentLink, "Expected document link should not be nil")
        XCTAssertNotNil(receivedRequestId, "Received request ID should not be nil")
        XCTAssertEqual(receivedRequestId, expectedPaymentRequestID, "Received request ID should match the expected payment request ID")
        XCTAssertEqual(documentLink, expectedDocumentLink, "Document link should match the expected document link")
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
        giniHealth.createPaymentRequest(paymentInfo: paymentInfo,
                                        completion: { result in
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
        XCTAssertNotNil(receivedRequestId, "Received request ID should not be nil")
        XCTAssertEqual(receivedRequestId, expectedPaymentRequestID, "Received request ID should match the expected payment request ID")
    }
    
    func testDeletePaymentRequestSuccess() {
        // Given
        let expectedPaymentRequestID = MockSessionManager.paymentRequestId

        // When
        let expectation = self.expectation(description: "Deleting payment request")
        var receivedRequestId: String?
        
        giniHealth.deletePaymentRequest(id: expectedPaymentRequestID,
                                        completion: { result in
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
        XCTAssertNotNil(receivedRequestId, "Received request ID should not be nil")
        XCTAssertEqual(receivedRequestId, expectedPaymentRequestID, "Received request ID should match the expected payment request ID")
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

        XCTAssertNotNil(receivedPaymentRequest, "Payment request should not be nil")
        XCTAssertEqual(receivedPaymentRequest?.expirationDate, expectedExpirationDate, "Expiration date should match")
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

        XCTAssertNotNil(receivedPaymentRequest, "Payment request should not be nil")
        XCTAssertNil(receivedPaymentRequest?.expirationDate, "Expiration date should be nil when not provided")
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

        XCTAssertNotNil(receivedPayment, "Received payment should not be nil")
        XCTAssertEqual(receivedPayment?.iban, expectedIBAN, "Payment IBAN should match")
    }
    
    // MARK: - Bulk Payment Request Deletion Tests

    @discardableResult
    private func deletePaymentRequestsExpectingError(ids: [String],
                                                     description: String) -> GiniHealthSDK.GiniError? {
        let exp = expectation(description: description)
        var receivedError: GiniHealthSDK.GiniError?

        giniHealth.paymentService.deletePaymentRequests(ids) { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                receivedError = GiniHealthSDK.GiniError.toGiniHealthSDKError(error: error)
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(receivedError, "Error should not be nil when deletion fails")
        return receivedError
    }

    func testDeletePaymentRequests_Unauthorized() {
        let unauthorizedIds = MockTestData.BulkDeletePaymentRequests.unauthorized
        let receivedError = deletePaymentRequestsExpectingError(ids: unauthorizedIds,
                                                               description: "Deleting payment requests with unauthorized error")
        XCTAssertEqual(receivedError?.items?.first?.code, "2016", "Error code should be 2016 for unauthorized")
        XCTAssertEqual(receivedError?.items?.first?.object, unauthorizedIds, "Error objects should match unauthorized IDs")
        XCTAssertEqual(receivedError?.requestId, "b608-02bb-c7g1-dd28-54e4-87b9", "Request ID should match")
    }
    
    func testDeletePaymentRequests_NotFound() {
        let notFoundIds = MockTestData.BulkDeletePaymentRequests.notFound
        let receivedError = deletePaymentRequestsExpectingError(ids: notFoundIds,
                                                               description: "Deleting payment requests with not found error")
        XCTAssertEqual(receivedError?.items?.first?.code, "2017", "Error code should be 2017 for not found")
        XCTAssertEqual(receivedError?.items?.first?.object, notFoundIds, "Error objects should match not-found IDs")
    }
    
    func testDeletePaymentRequests_Mixed() {
        let mixedIds = MockTestData.BulkDeletePaymentRequests.mixed
        let receivedError = deletePaymentRequestsExpectingError(ids: mixedIds,
                                                               description: "Deleting payment requests with mixed errors")
        XCTAssertEqual(receivedError?.items?.count, 2, "There should be 2 error items for mixed errors")
        
        // Verify both error codes are present
        let errorCodes = receivedError?.items?.map { $0.code } ?? []
        XCTAssertTrue(errorCodes.contains("2016"), "Error codes should contain 2016 for unauthorized")
        XCTAssertTrue(errorCodes.contains("2017"), "Error codes should contain 2017 for not found")
        
        // Verify objects are correctly assigned to each error code
        let unauthorizedObjects = receivedError?.objectsWithCode("2016") ?? []
        let notFoundObjects = receivedError?.objectsWithCode("2017") ?? []
        XCTAssertEqual(unauthorizedObjects, ["8d5h7630-8f16-11ec-bd63-31f9d04e200e", "92de6fec-4a7f-4376-b5d5-5155adf8adca"], "Unauthorized objects should match")
        XCTAssertEqual(notFoundObjects, ["bfb74b1b-567e-471e-ac5d-9e4494d0d049"], "Not-found objects should match")
    }
}
