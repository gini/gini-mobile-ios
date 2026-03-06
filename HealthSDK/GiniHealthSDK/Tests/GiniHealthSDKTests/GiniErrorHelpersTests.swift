import XCTest
@testable import GiniHealthSDK
import GiniHealthAPILibrary

final class GiniErrorHelpersTests: XCTestCase {
    
    // MARK: - itemsDescription Tests
    
    func testItemsDescription_withNoItems_returnsDefaultMessage() {
        // Given
        let error = GiniError.toGiniHealthSDKError(error: .noResponse)
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertEqual(description, "No specific error details")
    }
    
    func testItemsDescription_withRealTestFile_unauthorized() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotAuthorized", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertTrue(description.contains("2013"))
        XCTAssertTrue(description.contains("3db07630-8f16-11ec-bd63-31f9d04e200e"))
        XCTAssertTrue(description.contains("0db26fec-4a7f-4376-b5d5-5155adf8adca"))
    }
    
    func testItemsDescription_withRealTestFile_notFound() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotFound", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertTrue(description.contains("2014"))
        XCTAssertFalse(description.isEmpty)
    }
    
    func testItemsDescription_withRealTestFile_compositeMissing() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorCompositeMissing", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertTrue(description.contains("2015"))
        XCTAssertFalse(description.isEmpty)
    }
    
    func testItemsDescription_withNoObjects_showsNoObjects() {
        // Given
        let jsonData = """
        {
            "items": [
                {
                    "code": "2013"
                }
            ],
            "requestId": "test-id"
        }
        """.data(using: .utf8)!
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let description = error.itemsDescription
        
        // Then
        XCTAssertEqual(description, "2013: [no objects]")
    }
    
    // MARK: - objectsWithCode Tests
    
    func testObjectsWithCode_withNoItems_returnsEmptyArray() {
        // Given
        let error = GiniError.toGiniHealthSDKError(error: .noResponse)
        
        // When
        let objects = error.objectsWithCode("2013")
        
        // Then
        XCTAssertTrue(objects.isEmpty)
    }
    
    func testObjectsWithCode_withRealTestFile_unauthorized() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotAuthorized", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let objects = error.objectsWithCode("2013")
        
        // Then
        XCTAssertEqual(objects.count, 2)
        XCTAssertTrue(objects.contains("3db07630-8f16-11ec-bd63-31f9d04e200e"))
        XCTAssertTrue(objects.contains("0db26fec-4a7f-4376-b5d5-5155adf8adca"))
    }
    
    func testObjectsWithCode_withRealTestFile_notFound() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotFound", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let objects = error.objectsWithCode("2014")
        
        // Then
        XCTAssertEqual(objects.count, 2)
    }
    
    func testObjectsWithCode_withNonMatchingCode_returnsEmptyArray() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotFound", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When - Request code that doesn't exist in file
        let objects = error.objectsWithCode("9999")
        
        // Then
        XCTAssertTrue(objects.isEmpty)
    }
    
    func testObjectsWithCode_withMultipleItemsSameCode_mergesAllObjects() {
        // Given - Create test data with multiple items having same code
        let jsonData = """
        {
            "items": [
                {
                    "code": "2013",
                    "object": ["doc-1", "doc-2"]
                },
                {
                    "code": "2014",
                    "object": ["doc-3"]
                },
                {
                    "code": "2013",
                    "object": ["doc-4", "doc-5"]
                }
            ],
            "requestId": "test-id"
        }
        """.data(using: .utf8)!
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let objects = error.objectsWithCode("2013")
        
        // Then - Should merge all objects from both "2013" items
        XCTAssertEqual(objects.count, 4)
        XCTAssertEqual(objects, ["doc-1", "doc-2", "doc-4", "doc-5"])
    }
    
    // MARK: - detailedDescription Tests
    
    func testDetailedDescription_withRealTestFile_includesAllFields() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotAuthorized", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let response = HTTPURLResponse(
            url: URL(string: "https://api.gini.net")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: response,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let description = error.detailedDescription
        
        // Then
        XCTAssertTrue(description.contains("Status: 400"))
        XCTAssertTrue(description.contains("Request ID: a497-01aa-b6f0-cc17-43d3-76a8"))
        XCTAssertTrue(description.contains("Message:"))
        XCTAssertTrue(description.contains("Items: 2013:"))
    }
    
    func testDetailedDescription_withNoStatusCode_showsZero() {
        // Given - Use actual test resource without response
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotFound", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let description = error.detailedDescription
        
        // Then
        XCTAssertTrue(description.contains("Status: 0"))
        XCTAssertTrue(description.contains("Request ID: a497-01aa-b6f0-cc17-43d3-76a8"))
    }
    
    func testDetailedDescription_withMultipleRealFiles_formatsCorrectly() {
        // Given - Test all three error types
        let fileNames = [
            "bulkDocsDeletionErrorNotAuthorized",
            "bulkDocsDeletionErrorNotFound",
            "bulkDocsDeletionErrorCompositeMissing"
        ]
        
        for fileName in fileNames {
            guard let jsonData = FileLoader.loadFile(withName: fileName, ofType: "json") else {
                XCTFail("Failed to load test resource: \(fileName)")
                continue
            }
            
            let apiError = GiniHealthAPILibrary.GiniError.customError(
                response: nil,
                data: jsonData
            )
            let error = GiniError.toGiniHealthSDKError(error: apiError)
            
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
    
    func testMessage_customError_returnsAPIMessage() {
        // Given - Error with API message
        let jsonData = """
        {
            "message": "Documents could not be deleted due to authorization issues",
            "items": [
                {
                    "code": "2013",
                    "object": ["doc-1", "doc-2"]
                }
            ],
            "requestId": "test-request-123"
        }
        """.data(using: .utf8)!
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let message = error.message
        
        // Then - Should return the actual API message, not localized description
        XCTAssertEqual(message, "Documents could not be deleted due to authorization issues")
    }
    
    func testMessage_customError_withDecodingFailure_fallsBackToLocalizedDescription() {
        // Given - Invalid JSON that can't be decoded
        let invalidJsonData = "not valid json".data(using: .utf8)!
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: invalidJsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let message = error.message
        
        // Then - Should fall back to localizedDescription
        XCTAssertNotNil(message)
        XCTAssertNotEqual(message, "Documents could not be deleted due to authorization issues")
        // Will be something like "The operation couldn't be completed..."
    }
    
    func testMessage_customError_withRealTestFile_returnsMessage() {
        // Given - Use actual test resource
        guard let jsonData = FileLoader.loadFile(withName: "bulkDocsDeletionErrorNotAuthorized", ofType: "json") else {
            XCTFail("Failed to load test resource")
            return
        }
        
        let apiError = GiniHealthAPILibrary.GiniError.customError(
            response: nil,
            data: jsonData
        )
        let error = GiniError.toGiniHealthSDKError(error: apiError)
        
        // When
        let message = error.message
        
        // Then - Should return the message from the JSON file
        XCTAssertNotNil(message)
        XCTAssertFalse(message?.isEmpty ?? true)
        // The actual message will depend on what's in the test file
    }
    
    func testMessage_nonCustomError_returnsExpectedMessage() {
        // Given
        let noResponseError = GiniError.toGiniHealthSDKError(error: .noResponse)
        let notFoundError = GiniError.toGiniHealthSDKError(error: .notFound(response: nil, data: nil))
        let unauthorizedError = GiniError.toGiniHealthSDKError(error: .unauthorized(response: nil, data: nil))
        
        // Then
        XCTAssertEqual(noResponseError.message, "No response")
        XCTAssertEqual(notFoundError.message, "Not found")
        XCTAssertEqual(unauthorizedError.message, "Unauthorized")
    }
}

