import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthDocumentHandlingTests: XCTestCase {

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

    // MARK: - Delete Batch Of Documents Tests
    /// Enum for Delete  Batch Document Types
    private enum DeleteBatchDocumentType: String {
        case unauthorizedDocuments
        case notFoundDocuments
        case missingCompositeDocuments
        case success = ""
        case failure

        /// Expected failure response if applicable
        var expectedFailure: [String]? {
            switch self {
            case .unauthorizedDocuments, .notFoundDocuments, .missingCompositeDocuments:
                return [self.rawValue]
            default:
                return nil
            }
        }

        /// Expected success response if applicable
        var expectedSuccess: String? {
            self == .success ? "" : nil
        }
    }

    func testDeleteBatchDocumentsSuccess() {
        performDeleteBatchDocumentsTest(
            documentType: .success,
            description: "Deleting Batch Of Documents with Success"
        )
    }

    func testDeleteBatchDocumentsFailure() {
        performDeleteBatchDocumentsTest(
            documentType: .failure,
            description: "Deleting Batch Of Documents with Failure"
        )
    }

    func testDeleteBatchDocumentsErrorUnauthorizedDocuments() {
        performDeleteBatchDocumentsTest(
            documentType: .unauthorizedDocuments,
            description: "Deleting Batch Of Documents with Error of unauthorized documents"
        )
    }

    func testDeleteBatchDocumentsErrorNotFoundDocuments() {
        performDeleteBatchDocumentsTest(
            documentType: .notFoundDocuments,
            description: "Deleting Batch Of Documents with Error of not found documents"
        )
    }

    func testDeleteBatchDocumentsErrorMissingCompositeDocuments() {
        performDeleteBatchDocumentsTest(
            documentType: .missingCompositeDocuments,
            description: "Deleting Batch Of Documents with Error of missing composite documents"
        )
    }

    /// Helper Function for Delete Batch Documents Tests
    private func performDeleteBatchDocumentsTest(
        documentType: DeleteBatchDocumentType,
        description: String
    ) {
        let expectation = self.expectation(description: description)
        
        let documentIds = documentType == .failure ? [] : [documentType.rawValue]
        giniHealth.deleteDocuments(documentIds: documentIds) { result in
            switch result {
            case .success(let responseMessage):
                XCTAssertEqual(responseMessage, documentType.expectedSuccess)
            case .failure(let error):
                let receivedError = error.unauthorizedDocuments ?? error.notFoundDocuments ?? error.missingCompositeDocuments
                XCTAssertEqual(receivedError, documentType.expectedFailure)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
