import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthDocumentHandlingTests: GiniHealthTestCase {

    // MARK: - Setup / Teardown is inherited from GiniHealthTestCase

    // MARK: - Poll Document

    func testPollDocument_returnsDocument_whenSuccessful() throws {
        // Given
        let apiDocument: GiniHealthAPILibrary.Document = try XCTUnwrap(GiniHealthSDKTests.load(fromFile: "document1"))

        let expectedDocument = try XCTUnwrap(GiniHealthSDK.Document(healthDocument: apiDocument))

        // When
        let result = try XCTUnwrap(waitForResult {
            giniHealth.pollDocument(docId: MockSessionManager.payableDocumentID,
                                    completion: $0)
        })

        // Then
        switch result {
        case .success(let document):
            XCTAssertEqual(document, expectedDocument)
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testPollDocument_returnsError_whenDocumentMissing() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.pollDocument(docId: MockSessionManager.missingDocumentID,
                                    completion: $0)
        })
        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Set Document For Review

    func testSetDocumentForReview_returnsExtractions_whenSuccessful() throws {
        // Given
        let container: GiniHealthSDK.ExtractionsContainer =
        try XCTUnwrap(GiniHealthSDKTests.load(fromFile: "extractionsWithPayment"))

        let expectedExtractions = ExtractionResult(extractionsContainer: container)
            .payment?
            .first ?? []

        // When
        let result = try XCTUnwrap(waitForResult {
            giniHealth.setDocumentForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID,
                                            completion: $0)
        })

        // Then
        switch result {
        case .success(let extractions):
            XCTAssertEqual(extractions.count, expectedExtractions.count)
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    // MARK: - Fetch Data For Review

    func testFetchDataForReview_returnsDocumentAndExtractions_whenSuccessful() throws {
        // Given
        let container: GiniHealthSDK.ExtractionsContainer =
        try XCTUnwrap(GiniHealthSDKTests.load(fromFile: "extractionsWithPayment"))

        let expectedExtractions =
        ExtractionResult(extractionsContainer: container)
            .payment?
            .first ?? []

        let apiDocument: GiniHealthAPILibrary.Document =
        try XCTUnwrap(GiniHealthSDKTests.load(fromFile: "document4"))

        let expectedDocument =
        try XCTUnwrap(GiniHealthSDK.Document(healthDocument: apiDocument))

        let expectedData = DataForReview(document: expectedDocument,
                                         extractions: expectedExtractions)

        // When
        let result = try XCTUnwrap(waitForResult {
            giniHealth.fetchDataForReview(documentId: MockSessionManager.extractionsWithPaymentDocumentID,
                                          completion: $0)
        })

        // Then
        switch result {
        case .success(let data):
            XCTAssertEqual(data.document, expectedData.document)
            XCTAssertEqual(data.extractions.count,expectedData.extractions.count)
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testFetchDataForReview_returnsError_whenDocumentMissing() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.fetchDataForReview(documentId: MockSessionManager.missingDocumentID,
                                          completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }


    // MARK: - Delete Batch Documents

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

    // MARK: - Delete Batch Documents

    func testDeleteBatchDocuments_returnsSuccess_whenAllDocumentsValid() throws {
        let validIds = DeleteBatchDocumentType.success

        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: validIds, completion: $0)
        })

        switch result {
        case .success(let message):
            XCTAssertEqual(message, "")
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testDeleteBatchDocuments_returnsError_whenUnauthorized() throws {
        let unauthorizedIds = DeleteBatchDocumentType.unauthorizedDocuments

        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: unauthorizedIds, completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error.items)
            XCTAssertFalse(error.items?.isEmpty ?? true)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenDocumentsNotFound() throws {
        let notFoundIds = DeleteBatchDocumentType.notFoundDocuments

        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: notFoundIds, completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error.items)
            let errorObject = error.items?[0].object
            XCTAssertEqual(errorObject?.count, notFoundIds.count)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenCompositeItemsMissing() throws {
        let compositeMissingIds = DeleteBatchDocumentType.missingCompositeItems

        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: compositeMissingIds, completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error.items)
            let errorObject = error.items?[0].object
            XCTAssertEqual(errorObject?.count, compositeMissingIds.count)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenMixedFailureOccurs() throws {
        let mixedIds = DeleteBatchDocumentType.mixedNotFoundAndMissingCompositeItems

        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: mixedIds, completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error.items)
            let errorObject = error.items?[0].object
            XCTAssertEqual(errorObject?.count, mixedIds.count)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenEmptyIdsProvided() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: [], completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure when empty document IDs provided")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
}


