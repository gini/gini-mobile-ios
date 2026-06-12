import XCTest
@testable import GiniHealthSDK
import GiniHealthAPILibrary

final class GiniErrorHelpersTests: XCTestCase {

    // MARK: - Helper

    /// Loads a JSON test fixture, wraps it in `.customError`, and converts it to a `GiniHealthSDK.GiniError`.
    private func makeSDKError(fromFile fileName: String,
                              response: HTTPURLResponse? = nil) -> GiniHealthSDK.GiniError {
        guard let jsonData = FileLoader.loadFile(withName: fileName, ofType: "json") else {
            XCTFail("Failed to load test resource: \(fileName).json")
            return GiniError.toGiniHealthSDKError(error: .noResponse)
        }
        let apiError = GiniHealthAPILibrary.GiniError.customError(response: response, data: jsonData)
        return GiniError.toGiniHealthSDKError(error: apiError)
    }
    
    // MARK: - itemsDescription Tests
    
    func testItemsDescriptionWithNoItemsReturnsDefaultMessage() {
        // Given
        let error = GiniError.toGiniHealthSDKError(error: .noResponse)
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertEqual(description, "No specific error details", "Description should be the default message when no items are present")
    }
    
    func testItemsDescriptionWithRealTestFileUnauthorized() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotAuthorized")
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertTrue(description.contains("2013"), "Description should contain error code 2013")
        XCTAssertTrue(description.contains("3db07630-8f16-11ec-bd63-31f9d04e200e"), "Description should contain the first unauthorized document ID")
        XCTAssertTrue(description.contains("0db26fec-4a7f-4376-b5d5-5155adf8adca"), "Description should contain the second unauthorized document ID")
    }
    
    func testItemsDescriptionWithRealTestFileNotFound() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotFound")
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertTrue(description.contains("2014"), "Description should contain error code 2014")
        XCTAssertFalse(description.isEmpty, "Description should not be empty for notFound error")
    }
    
    func testItemsDescriptionWithRealTestFileCompositeMissing() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorCompositeMissing")
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertTrue(description.contains("2015"), "Description should contain error code 2015")
        XCTAssertFalse(description.isEmpty, "Description should not be empty for compositeMissing error")
    }
    
    func testItemsDescriptionWithNoObjectsShowsNoObjects() {
        let error = makeSDKError(fromFile: "itemsWithErrorCodeAndWithoutObject")
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertEqual(description, "2013: [no objects]", "Description should indicate no objects for the given error code")
    }
    
    // MARK: - objectsWithCode Tests
    
    func testObjectsWithCodeWithNoItemsReturnsEmptyArray() {
        // Given
        let error = GiniError.toGiniHealthSDKError(error: .noResponse)
        
        // When
        let objects = error.objectsWithCode("2013")
        
        // Then
        XCTAssertTrue(objects.isEmpty, "Objects should be empty when no items are present")
    }
    
    func testObjectsWithCodeWithRealTestFileUnauthorized() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotAuthorized")
        
        // When
        let objects = error.objectsWithCode("2013")
        
        // Then
        XCTAssertEqual(objects.count, 2, "There should be 2 objects for code 2013")
        XCTAssertTrue(objects.contains("3db07630-8f16-11ec-bd63-31f9d04e200e"), "Objects should contain the first unauthorized document ID")
        XCTAssertTrue(objects.contains("0db26fec-4a7f-4376-b5d5-5155adf8adca"), "Objects should contain the second unauthorized document ID")
    }
    
    func testObjectsWithCodeWithRealTestFileNotFound() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotFound")
        
        // When
        let objects = error.objectsWithCode("2014")
        
        // Then
        XCTAssertEqual(objects.count, 2, "There should be 2 objects for code 2014")
    }
    
    func testObjectsWithCodeWithNonMatchingCodeReturnsEmptyArray() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotFound")
        
        // When - Request code that doesn't exist in file
        let objects = error.objectsWithCode("9999")
        
        // Then
        XCTAssertTrue(objects.isEmpty, "Objects should be empty for a non-matching error code")
    }
    
    func testObjectsWithCodeWithMultipleItemsSameCodeMergesAllObjects() {
        let error = makeSDKError(fromFile: "multipleItemsSameErrorCode")
        
        // When
        let objects = error.objectsWithCode("2013")
        
        // Then - Should merge all objects from both "2013" items
        XCTAssertEqual(objects.count, 4, "Objects should be merged from all items with the same error code")
        XCTAssertEqual(objects, ["doc-1", "doc-2", "doc-4", "doc-5"], "Merged objects should match in order")
    }
    
    // MARK: - detailedDescription Tests
    
    func testDetailedDescriptionWithRealTestFileIncludesAllFields() {
        guard let url = URL(string: "https://pay-api.gini.net"),
              let response = HTTPURLResponse(url: url,
                                             statusCode: 400,
                                             httpVersion: nil,
                                             headerFields: nil) else {
            XCTFail("Failed to create HTTPURLResponse")
            return
        }
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotAuthorized", response: response)
        
        // When
        let description = error.detailedDescription
        
        // Then
        XCTAssertTrue(description.contains("Status: 400"), "Description should contain the HTTP status code")
        XCTAssertTrue(description.contains("Request ID: a497-01aa-b6f0-cc17-43d3-76a8"), "Description should contain the request ID")
        XCTAssertTrue(description.contains("Message:"), "Description should contain the Message field")
        XCTAssertTrue(description.contains("Items: 2013:"), "Description should contain the error items")
    }
    
    func testDetailedDescriptionWithNoStatusCodeShowsZero() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotFound")
        
        // When
        let description = error.detailedDescription
        
        // Then
        XCTAssertTrue(description.contains("Status: 0"), "Description should show status 0 when no HTTP response is provided")
        XCTAssertTrue(description.contains("Request ID: a497-01aa-b6f0-cc17-43d3-76a8"), "Description should contain the request ID")
    }
    
    func testDetailedDescriptionWithMultipleRealFilesFormatsCorrectly() {
        // Given - Test all three error types
        let fileNames = [
            "bulkDocsDeletionErrorNotAuthorized",
            "bulkDocsDeletionErrorNotFound",
            "bulkDocsDeletionErrorCompositeMissing"
        ]
        
        for fileName in fileNames {
            let error = makeSDKError(fromFile: fileName)
            
            // When
            let description = error.detailedDescription
            
            // Then - Should contain all required fields
            XCTAssertTrue(description.contains("Status:"), "Missing status in \(fileName)")
            XCTAssertTrue(description.contains("Request ID:"), "Missing requestId in \(fileName)")
            XCTAssertTrue(description.contains("Message:"), "Missing message in \(fileName)")
            XCTAssertTrue(description.contains("Items:"), "Missing items in \(fileName)")
        }
    }
    
    // MARK: - message Property Tests
    
    func testMessageCustomErrorReturnsAPIMessage() {
        let error = makeSDKError(fromFile: "itemWithErrorCodeAndAPIMessage")
        
        // When
        let message = error.message
        
        // Then - Should return the actual API message, not localized description
        XCTAssertEqual(message, "Documents could not be deleted due to authorization issues", "Message should match the API error message")
    }
    
    func testMessageCustomErrorWithDecodingFailureFallsBackToLocalizedDescription() {
        // Given - Invalid JSON that can't be decoded
        guard let invalidJsonData = "not valid json".data(using: .utf8) else {
            XCTFail("Failed to create invalid JSON data")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(response: nil,
                                                                  data: invalidJsonData)

        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let message = error.message
        
        // Then - Should fall back to localizedDescription
        XCTAssertNotNil(message, "Message should not be nil even when JSON is invalid")
        XCTAssertNotEqual(message, "Documents could not be deleted due to authorization issues", "Message should not be the API error message when JSON decoding fails")
        // Will be something like "The operation couldn't be completed..."
    }
    
    func testMessageCustomErrorWithRealTestFileReturnsMessage() {
        let error = makeSDKError(fromFile: "bulkDocsDeletionErrorNotAuthorized")
        
        // When
        let message = error.message
        
        // Then - Should return the message from the JSON file
        XCTAssertNotNil(message, "Message should not be nil for a custom error with valid JSON")
        XCTAssertFalse(message?.isEmpty ?? true, "Message should not be empty")
        // The actual message will depend on what's in the test file
    }
    
    func testMessageNonCustomErrorReturnsExpectedMessage() {
        // Given
        let noResponseError = GiniError.toGiniHealthSDKError(error: .noResponse)
        let notFoundError = GiniError.toGiniHealthSDKError(error: .notFound(response: nil,
                                                                            data: nil))
        let unauthorizedError = GiniError.toGiniHealthSDKError(error: .unauthorized(response: nil,
                                                                                    data: nil))

        // Then
        XCTAssertEqual(noResponseError.message, "No response", "NoResponse error message should be 'No response'")
        XCTAssertEqual(notFoundError.message, "Not found", "NotFound error message should be 'Not found'")
        XCTAssertEqual(unauthorizedError.message, "Unauthorized", "Unauthorized error message should be 'Unauthorized'")
    }
}
