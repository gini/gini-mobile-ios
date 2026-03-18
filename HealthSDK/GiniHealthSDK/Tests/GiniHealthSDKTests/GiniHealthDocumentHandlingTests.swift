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

    func testDeleteBatchDocuments_returnsSuccess_whenAllDocumentsValid() throws {
        let result = try XCTUnwrap(waitForResult {
            giniHealth.deleteDocuments(documentIds: DeleteBatchDocumentType.success, completion: $0)
        })
        switch result {
        case .success(let message):
            XCTAssertEqual(message, "")
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    func testDeleteBatchDocuments_returnsError_whenUnauthorized() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.unauthorizedDocuments) { error in
            XCTAssertNotNil(error.items)
            XCTAssertFalse(error.items?.isEmpty ?? true)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenDocumentsNotFound() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.notFoundDocuments) { error in
            XCTAssertNotNil(error.items)
            XCTAssertEqual(error.items?[0].object?.count, DeleteBatchDocumentType.notFoundDocuments.count)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenCompositeItemsMissing() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.missingCompositeItems) { error in
            XCTAssertNotNil(error.items)
            XCTAssertEqual(error.items?[0].object?.count, DeleteBatchDocumentType.missingCompositeItems.count)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenMixedFailureOccurs() throws {
        try assertDeleteDocumentsFails(documentIds: DeleteBatchDocumentType.mixedNotFoundAndMissingCompositeItems) { error in
            XCTAssertNotNil(error.items)
            XCTAssertEqual(error.items?[0].object?.count, DeleteBatchDocumentType.mixedNotFoundAndMissingCompositeItems.count)
        }
    }

    func testDeleteBatchDocuments_returnsError_whenEmptyIdsProvided() throws {
        try assertDeleteDocumentsFails(documentIds: []) { error in
            XCTAssertNotNil(error)
        }
    }
}


