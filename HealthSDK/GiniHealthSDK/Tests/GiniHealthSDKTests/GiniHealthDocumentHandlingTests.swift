import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthDocumentHandlingTests: XCTestCase {

    var giniHealthAPI: GiniHealthAPI!
    var giniHealth: GiniHealth!
    private let versionAPI = 5

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

    func testPollDocumentSuccess() {
        // Given
        let healthDocument: GiniHealthAPILibrary.Document = GiniHealthSDKTests.load(fromFile: "document1")!
        let expectedDocument: GiniHealthSDK.Document? = GiniHealthSDK.Document(healthDocument: healthDocument)

        // When
        let expectation = self.expectation(description: "Polling document")
        var receivedDocument: GiniHealthSDK.Document?
        giniHealth.pollDocument(docId: MockSessionManager.payableDocumentID) { result in
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
    
    func testPollDocumentFailure() {
        // When
        let expectation = self.expectation(description: "Polling failure document")
        var receivedDocument: GiniHealthSDK.Document?
        giniHealth.pollDocument(docId: MockSessionManager.missingDocumentID) { result in
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

    func testSetDocumentForReviewSuccess() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniHealthSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []

        // When
        let expectation = self.expectation(description: "Setting document for review")
        var receivedExtractions: [GiniHealthSDK.Extraction]?
        giniHealth.setDocumentForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
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
    
    func testFetchDataForReviewSuccess() {
        // Given
        let fileName = "extractionsWithPayment"
        let expectedExtractionContainer: GiniHealthSDK.ExtractionsContainer? = GiniHealthSDKTests.load(fromFile: fileName)
        guard let expectedExtractionContainer else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        let expectedExtractions: [GiniHealthSDK.Extraction] = ExtractionResult(extractionsContainer: expectedExtractionContainer).payment?.first ?? []
        let documentFileName = "document4"

        let healthDocument: GiniHealthAPILibrary.Document = GiniHealthSDKTests.load(fromFile: documentFileName)!
        let expectedDocument: GiniHealthSDK.Document? = GiniHealthSDK.Document(healthDocument: healthDocument)

        guard let expectedDocument else {
            XCTFail("Error loading file: `\(documentFileName).json`")
            return
        }
        let expectedDatForReview = DataForReview(document: expectedDocument, extractions: expectedExtractions)

        // When
        let expectation = self.expectation(description: "Fetching data for review")
        var receivedDataForReview: DataForReview?
        giniHealth.fetchDataForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID) { result in
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
    
    func testFetchDataForReviewFailure() {
        // When
        let expectation = self.expectation(description: "Failure fetching data for review")
        var receivedError: GiniHealthError?
        giniHealth.fetchDataForReview(documentId: MockSessionManager.missingDocumentID) { result in
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

//    func testIfDeleteBatchDocumentsFailure() {
//        // Given
//        let fileName = "batchDocumentDeletionFaillureDocsNotFound"
//        // Load expected error response from fixtures
//        let expectedError: GiniCustomError? = GiniHealthSDKTests.load(
//            fromFile: fileName
//        )
//        guard let expectedError else {
//            XCTFail("Error loading file: `\(fileName).json`")
//            return
//        }
//
//        // When
//        let expectation = self.expectation(description: "Checking delete batch documents failure")
//        var receivedErrorItems: [ErrorItem]?
//        let documentsToDeleteIds = ["3db07630-8f16-11ec-bd63-31f9d04e200e", "0db26fec-4a7f-4376-b5d5-5155adf8adca"] as [String]
//        giniHealth.deleteDocuments(documentIds: documentsToDeleteIds) { result in
//            switch result {
//            case .success:
//                XCTFail("Test should fail, but it passed")
//            case .failure(let error):
//                receivedErrorItems = error.items
//            }
//            expectation.fulfill()
//        }
//        waitForExpectations(timeout: 1, handler: nil)
//
//        // Then
//        XCTAssertNotNil(receivedErrorItems)
//        XCTAssertEqual(receivedErrorItems?.count, expectedError.items?.count)
//    }

    // MARK: - Delete Batch Of Documents Tests
    private enum DeleteBatchDocumentType {
        static let notFoundDocuments: [String] = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        static let unauthorizedDocuments: [String] = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        static let missingCompositeItems: [String] = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        static let mixedNotFoundAndNotUnAuthorizedDocuments: [String] = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        static let mixedNotFoundAndMissingCompositeItems: [String] = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        static let mixedNotFoundAndUnAuthorizedAndMissingCompositeItems: [String] = [
            "3db07630-8f16-11ec-bd63-31f9d04e200e",
            "0db26fec-4a7f-4376-b5d5-5155adf8adca"
        ]
        static let success: [String] = [""]
    }

    func testDeleteBatchDocumentsSuccess() {
        performDeleteBatchDocumentsTest(
            documentIds: DeleteBatchDocumentType.success,
            description: "Deleting Batch Of Documents with Success",
            expectSuccess: true
        )
    }

//    func testDeleteBatchDocumentsFailure() {
//        performDeleteBatchDocumentsTest(
//            documentIds: [],
//            description: "Deleting Batch Of Documents with Failure",
//            expectSuccess: false
//        )
//    }

    func testDeleteBatchDocumentsErrorUnauthorizedDocuments() {
        performDeleteBatchDocumentsTest(
            documentIds: DeleteBatchDocumentType.unauthorizedDocuments,
            description: "Deleting Batch Of Documents with Error of unauthorized documents",
            expectSuccess: false
        )
    }

    func testDeleteBatchDocumentsErrorNotFoundDocuments() {
        performDeleteBatchDocumentsTest(
            documentIds: DeleteBatchDocumentType.notFoundDocuments,
            description: "Deleting Batch Of Documents with Error of not found documents",
            expectSuccess: false
        )
    }

    func testDeleteBatchDocumentsErrorMissingCompositeDocuments() {
        performDeleteBatchDocumentsTest(
            documentIds: DeleteBatchDocumentType.missingCompositeItems,
            description: "Deleting Batch Of Documents with Error of missing composite documents",
            expectSuccess: false
        )
    }

    /// Helper Function for Delete Batch Documents Tests
    private func performDeleteBatchDocumentsTest(
        documentIds: [String],
        description: String,
        expectSuccess: Bool
    ) {
        let expectation = self.expectation(description: description)
        var receivedErrorItems: [ErrorItem]?

        giniHealth.deleteDocuments(documentIds: documentIds) { result in
            switch result {
            case .success(let responseMessage):
                if expectSuccess {
                    // For success path, responseMessage is expected to be a non-empty confirmation
                    XCTAssertTrue(responseMessage == "")
                } else {
                    XCTFail("Expected failure but received success: \(responseMessage)")
                }
            case .failure(let error):
                if expectSuccess {
                    XCTFail("Expected success but received error: \(error)")
                } else {
                    receivedErrorItems = error.items
                    XCTAssertTrue(receivedErrorItems?.isNotEmpty == true)
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

