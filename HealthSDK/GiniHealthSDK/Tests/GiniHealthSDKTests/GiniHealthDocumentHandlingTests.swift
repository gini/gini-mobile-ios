import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthDocumentHandlingTests: GiniHealthTestCase {

    // MARK: - Setup / Teardown is inherited from GiniHealthTestCase

    // MARK: - Poll Document

    func testPollDocumentReturnsDocumentWhenSuccessful() throws {
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
            XCTAssertEqual(document, expectedDocument, "Returned document should match the expected document")
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testPollDocumentReturnsErrorWhenDocumentMissing() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.pollDocument(docId: MockSessionManager.missingDocumentID,
                                    completion: $0)
        })
        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error, "Error should not be nil when document is missing")
        }
    }

    // MARK: - Set Document For Review

    func testSetDocumentForReviewReturnsExtractionsWhenSuccessful() throws {
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
            XCTAssertEqual(extractions.count, expectedExtractions.count, "Returned extractions count should match expected count")
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    // MARK: - Fetch Data For Review

    func testFetchDataForReviewReturnsDocumentAndExtractionsWhenSuccessful() throws {
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
            XCTAssertEqual(data.document, expectedData.document, "Returned document should match expected document")
            XCTAssertEqual(data.extractions.count, expectedData.extractions.count, "Returned extractions count should match expected count")
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testFetchDataForReviewReturnsErrorWhenDocumentMissing() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.fetchDataForReview(documentId: MockSessionManager.missingDocumentID,
                                          completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error, "Error should not be nil when document is missing")
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

    private func assertDeleteDocumentsFails(
        documentIds: [String],
        validate: (GiniHealthSDK.GiniError) -> Void
    ) throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: documentIds, completion: $0)
        })
        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            validate(error)
        }
    }

    func testDeleteBatchDocumentsReturnsSuccessWhenAllDocumentsValid() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: DeleteBatchDocumentType.success, completion: $0)
        })
        switch result {
        case .success(let message):
            XCTAssertEqual(message, "", "Success message should be empty when all documents are deleted")
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testDeleteBatchDocumentsReturnsErrorWhenUnauthorized() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.unauthorizedDocuments) { error in
            XCTAssertNotNil(error.items, "Error items should not be nil for unauthorized deletion")
            XCTAssertFalse(error.items?.isEmpty ?? true, "Error items should not be empty for unauthorized deletion")
        }
    }

    func testDeleteBatchDocumentsReturnsErrorWhenDocumentsNotFound() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.notFoundDocuments) { error in
            XCTAssertNotNil(error.items, "Error items should not be nil for not-found documents")
            XCTAssertEqual(error.items?[0].object?.count, DeleteBatchDocumentType.notFoundDocuments.count, "Object count should match not-found documents count")
        }
    }

    func testDeleteBatchDocumentsReturnsErrorWhenCompositeItemsMissing() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.missingCompositeItems) { error in
            XCTAssertNotNil(error.items, "Error items should not be nil for missing composite items")
            XCTAssertEqual(error.items?[0].object?.count, DeleteBatchDocumentType.missingCompositeItems.count, "Object count should match missing composite items count")
        }
    }

    func testDeleteBatchDocumentsReturnsErrorWhenMixedFailureOccurs() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.mixedNotFoundAndMissingCompositeItems) { error in
            XCTAssertNotNil(error.items, "Error items should not be nil for mixed failure")
            XCTAssertEqual(error.items?[0].object?.count, DeleteBatchDocumentType.mixedNotFoundAndMissingCompositeItems.count, "Object count should match mixed-failure documents count")
        }
    }

    func testDeleteBatchDocumentsReturnsErrorWhenEmptyIdsProvided() throws {
        try assertDeleteDocumentsFails(documentIds: []) { error in
            XCTAssertNotNil(error, "Error should not be nil when no document IDs are provided")
        }
    }

    // MARK: - Set Document For Review (failure path)

    func testSetDocumentForReviewReturnsErrorWhenDocumentMissing() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.setDocumentForReview(documentId: MockSessionManager.missingDocumentID,
                                            completion: $0)
        })

        switch result {
        case .success:
            XCTFail("Expected failure but received success")
        case .failure(let error):
            XCTAssertNotNil(error, "Error should not be nil when document is missing")
        }
    }
}


