//
//  GiniMerchantTests.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniUtilites
@testable import GiniMerchantSDK
@testable import GiniHealthAPILibrary

final class GiniMerchantTests: XCTestCase {
    
    var giniHealthAPI: GiniHealthAPI!
    var giniMerchant: GiniMerchant!
    private let versionAPI = 1

    override func setUp() {
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock, apiDomain: .merchant, apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock, apiDomain: .merchant, apiVersion: versionAPI)
        giniHealthAPI = GiniHealthAPI(documentService: documentService, paymentService: paymentService)
        giniMerchant = GiniMerchant(giniApiLib: giniHealthAPI)
    }

    override func tearDown() {
        giniMerchant = nil
        super.tearDown()
    }
    
    func testSetConfiguration() throws {
        // Given
        let configuration = GiniMerchantConfiguration()
        
        // When
        giniMerchant.setConfiguration(configuration)
        
        // Then
        XCTAssertEqual(GiniMerchantConfiguration.shared, configuration)
    }
    
    func testFetchBankingApps_Success() {
        // Given
        let expectedProviders: [GiniMerchantSDK.PaymentProvider]? = loadProviders(fileName: "providers")
        
        // When
        let expectation = self.expectation(description: "Fetching banking apps")
        var receivedProviders: [GiniMerchantSDK.PaymentProvider]?
        giniMerchant.fetchBankingApps { result in
            switch result {
            case .success(let providers):
                receivedProviders = providers
            case .failure(_):
                receivedProviders = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        // Then
        XCTAssertNotNil(receivedProviders)
        XCTAssertEqual(receivedProviders?.count, expectedProviders?.count)
        XCTAssertEqual(receivedProviders, expectedProviders)
    }

    func testCheckIfDocumentIsPayable_Success() {
        // Given
        let fileName = "extractionResultWithIBAN"
        let expectedExtractions: GiniMerchantSDK.ExtractionsContainer? = GiniMerchantSDKTests.load(fromFile: fileName)
        guard let expectedExtractions else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractionsResult = ExtractionResult(extractionsContainer: expectedExtractions)
        let expectedIsPayable = expectedExtractionsResult.extractions.first(where: { $0.name == "iban" })?.value.isNotEmpty
        
        // When
        let expectation = self.expectation(description: "Checking if document is payable")
        var isDocumentPayable: Bool?
        giniMerchant.checkIfDocumentIsPayable(docId: MockSessionManager.payableDocumentID) { result in
            switch result {
            case .success(let isPayable):
                isDocumentPayable = isPayable
            case .failure(_):
                isDocumentPayable = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertEqual(expectedIsPayable, isDocumentPayable)
    }
    
    func testCheckIfDocumentIsNotPayable_Success() {
        // Given
        let fileName = "extractionResultWithIBAN"
        let expectedExtractions: GiniMerchantSDK.ExtractionsContainer? = GiniMerchantSDKTests.load(fromFile: fileName)
        guard let expectedExtractions else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractionsResult = ExtractionResult(extractionsContainer: expectedExtractions)
        let expectedIsPayable = expectedExtractionsResult.extractions.first(where: { $0.name == "iban" })?.value.isEmpty
        
        // When
        let expectation = self.expectation(description: "Checking if document is not payable")
        var isDocumentPayable: Bool?
        giniMerchant.checkIfDocumentIsPayable(docId: MockSessionManager.notPayableDocumentID) { result in
            switch result {
            case .success(let isPayable):
                isDocumentPayable = isPayable
            case .failure(_):
                isDocumentPayable = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertEqual(expectedIsPayable, isDocumentPayable)
    }
    
    func testCheckIfDocumentIsPayable_Failure() {
        // When
        let expectation = self.expectation(description: "Checking if request fails")
        var isDocumentPayable: Bool?
        giniMerchant.checkIfDocumentIsPayable(docId: MockSessionManager.failurePayableDocumentID) { result in
            switch result {
            case .success(let isPayable):
                isDocumentPayable = isPayable
            case .failure(_):
                isDocumentPayable = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(isDocumentPayable)
    }
    
    func testPollDocument_Success() {
        // Given
        let healthDocument: GiniHealthAPILibrary.Document = GiniMerchantSDKTests.load(fromFile: "document1")!
        let expectedDocument: GiniMerchantSDK.Document? = GiniMerchantSDK.Document(healthDocument: healthDocument)
        
        // When
        let expectation = self.expectation(description: "Polling document")
        var receivedDocument: GiniMerchantSDK.Document?
        giniMerchant.pollDocument(docId: MockSessionManager.payableDocumentID) { result in
            switch result {
            case .success(let document):
                receivedDocument = document
            case .failure(_):
                receivedDocument = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedDocument)
        XCTAssertEqual(receivedDocument, expectedDocument)
    }
    
    func testPollDocument_Failure() {
        // When
        let expectation = self.expectation(description: "Polling failure document")
        var receivedDocument: GiniMerchantSDK.Document?
        giniMerchant.pollDocument(docId: MockSessionManager.missingDocumentID) { result in
            switch result {
            case .success(let document):
                receivedDocument = document
            case .failure(_):
                receivedDocument = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(receivedDocument)
    }
    
    func testGetExtractions_Success() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniMerchantSDK.ExtractionsContainer? = GiniMerchantSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniMerchantSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []

        // When
        let expectation = self.expectation(description: "Getting extractions")
        var receivedExtractions: [GiniMerchantSDK.Extraction]?
        giniMerchant.getExtractions(docId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedExtractions = extractions
            case .failure(_):
                receivedExtractions = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedExtractions)
        XCTAssertEqual(receivedExtractions?.count, expectedExtractions.count)
    }
    
    func testGetExtractions_Failure() {
        // When
        let expectation = self.expectation(description: "Extraction failure")
        var receivedExtractions: [GiniMerchantSDK.Extraction]?
        giniMerchant.getExtractions(docId: MockSessionManager.failurePayableDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedExtractions = extractions
            case .failure(_):
                receivedExtractions = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(receivedExtractions)
    }
    
    func testCreatePaymentRequest_Success() {
        // Given
        let expectedPaymentRequestID = MockSessionManager.paymentRequestId

        // When
        let expectation = self.expectation(description: "Creating payment request")
        var receivedRequestId: String?
        let paymentInfo = PaymentInfo(recipient: "Uno Flüchtlingshilfe", iban: "DE78370501980020008850", bic: "COLSDE33", amount: "1.00:EUR", purpose: "ReNr 12345", paymentUniversalLink: "ginipay-test://paymentRequester", paymentProviderId: "b09ef70a-490f-11eb-952e-9bc6f4646c57")
        giniMerchant.createPaymentRequest(paymentInfo: paymentInfo, completion: { result in
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
    
    func testOpenLink_Success() {
        let mockUIApplication = MockUIApplication(canOpen: true)
        let urlOpener = URLOpener(mockUIApplication)
        let waitForWebsiteOpen = expectation(description: "Link was opened")

        giniMerchant.openPaymentProviderApp(requestID: "123", universalLink: "ginipay-bank://", urlOpener: urlOpener, completion: { open in
            waitForWebsiteOpen.fulfill()
            XCTAssert(open, "testOpenLink - FAILED to open link")
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testOpenLink_Failure() {
        let mockUIApplication = MockUIApplication(canOpen: false)
        let urlOpener = URLOpener(mockUIApplication)
        let waitForWebsiteOpen = expectation(description: "Link was not opened")

        giniMerchant.openPaymentProviderApp(requestID: "123", universalLink: "ginipay-bank://", urlOpener: urlOpener, completion: { open in
            waitForWebsiteOpen.fulfill()
            XCTAssert(open == false, "testOpenLink - MANAGED to open link")
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testSetDocumentForReview_Success() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniMerchantSDK.ExtractionsContainer? = GiniMerchantSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniMerchantSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []

        // When
        let expectation = self.expectation(description: "Setting document for review")
        var receivedExtractions: [GiniMerchantSDK.Extraction]?
        giniMerchant.setDocumentForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
            switch result {
            case .success(let extractions):
                receivedExtractions = extractions
            case .failure(_):
                receivedExtractions = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedExtractions)
        XCTAssertEqual(receivedExtractions?.count, expectedExtractions.count)
    }
    
    func testFetchDataForReview_Success() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniMerchantSDK.ExtractionsContainer? = GiniMerchantSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniMerchantSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []
        let documentFileName = "document4"
        
        let healthDocument: GiniHealthAPILibrary.Document = GiniMerchantSDKTests.load(fromFile: documentFileName)!
        let expectedDocument: GiniMerchantSDK.Document? = GiniMerchantSDK.Document(healthDocument: healthDocument)

        guard let expectedDocument else {
            XCTFail("Error loading file: `\(documentFileName).json`")
            return
        }
        let expectedDatForReview = DataForReview(document: expectedDocument, extractions: expectedExtractions)

        // When
        let expectation = self.expectation(description: "Fetching data for review")
        var receivedDataForReview: DataForReview?
        giniMerchant.fetchDataForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
            switch result {
            case .success(let dataForReview):
                receivedDataForReview = dataForReview
            case .failure(_):
                receivedDataForReview = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedDataForReview)
        XCTAssertEqual(receivedDataForReview?.document, expectedDatForReview.document)
        XCTAssertEqual(receivedDataForReview?.extractions.count, expectedDatForReview.extractions.count)
    }
    
    func testFetchDataForReview_Failure() {
        // When
        let expectation = self.expectation(description: "Failure fetching data for review")
        var receivedError: GiniMerchantError?
        giniMerchant.fetchDataForReview(documentId: MockSessionManager.missingDocumentID) { result in
            switch result {
            case .success(_):
                receivedError = nil
            case .failure(let error):
                receivedError = error
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(receivedError)
    }
}
