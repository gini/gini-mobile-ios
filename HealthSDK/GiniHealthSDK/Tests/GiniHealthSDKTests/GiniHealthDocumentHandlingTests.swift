import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class GiniHealthDocumentHandlingTests: XCTestCase {

    // MARK: - Properties

    var giniHealthAPI: GiniHealthAPI!
    var giniHealth: GiniHealth!
    private let versionAPI = 5
    private let timeout: TimeInterval = 2

    // MARK: - Setup / Teardown

    override func setUp() {
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock,
                                                     apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock,
                                            apiVersion: versionAPI)
        let clientConfigurationService = ClientConfigurationService(sessionManager: sessionManagerMock,
                                                                    apiVersion: versionAPI)
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

    /// Waits synchronously for an asynchronous operation to complete and returns its Result.
    ///
    /// This helper is intended for use in unit tests to bridge callback-based APIs into a
    /// synchronous flow. It creates an XCTest expectation, invokes the provided `action` with
    /// a completion handler, and blocks the test until the completion is called or the test's
    /// timeout is reached. The captured `Result` is then returned to the caller.
    ///
    /// - Note:
    ///   - This method should only be used from within XCTest cases, as it relies on
    ///     XCTest's expectation mechanism.
    ///   - The enclosing test case's `timeout` is used to wait for the expectation; if the
    ///     expectation is not fulfilled within that time, the test will fail gracefully by
    ///     returning `nil`. Use `XCTUnwrap` at call sites to ensure the result exists.
    ///
    /// - Parameter action: A closure that starts the asynchronous work. It receives a completion
    ///   closure to be called with a `Result<T, E>` when the work finishes.
    ///   Example:
    ///   ```swift
    ///   let result = try XCTUnwrap(waitForResult { completion in
    ///       api.doSomething { outcome in
    ///           completion(outcome)
    ///       }
    ///   })
    ///   ```
    ///
    /// - Returns: The `Result<T, E>` produced by the asynchronous operation, or `nil` if the
    ///   expectation times out. On success, it contains the expected value of type `T`; on
    ///   failure, it contains an error of type `E`.
    ///
    /// - SeeAlso: `XCTestCase.expectation(description:)`, `XCTestCase.waitForExpectations(timeout:handler:)`
    /// - Important: Always ensure that the asynchronous operation being tested calls the provided completion handler, otherwise the test will timeout and return nil.
    @discardableResult
    private func waitForResult<T, E: Error>(_ action: (@escaping (Result<T, E>) -> Void) -> Void) -> Result<T, E>? {
        let expectation = expectation(description: "Awaiting async result")
        var capturedResult: Result<T, E>?

        action {
            capturedResult = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        return capturedResult
    }
}

