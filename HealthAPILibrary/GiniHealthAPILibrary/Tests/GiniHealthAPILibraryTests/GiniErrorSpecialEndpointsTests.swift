//
//  GiniErrorSpecialEndpointsTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini. All rights reserved.
//
import XCTest
@testable import GiniHealthAPILibrary

final class GiniErrorSpecialEndpointsTests: XCTestCase {

    // Verifies that a notFound error with custom JSON body decodes items and requestId,
    // and exposes the HTTP status code from the response.
    func testNotFoundError_decodesItemsAndRequestId() {
        // Given
        let errorData = loadFile(withName: "notFoundError", ofType: "json")

        guard let url = URL(string: "https://api.gini.net/documents/b4bd3e80-7bd1-11e4-95ab-000000000000") else {
            XCTFail("Invalid URL")
            return
        }
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)

        // When
        let error = GiniError.notFound(response: response, data: errorData)

        // Then
        XCTAssertEqual(error.statusCode, 404, "Status code should be 404 for notFound")
        XCTAssertEqual(error.requestId, "req-123456", "Request ID should be decoded from error body")

        let items = error.items
        XCTAssertNotNil(items, "Items should be decoded for notFound error with body")
        XCTAssertEqual(items?.count, 1, "There should be exactly one error item")

        let first = items?.first
        XCTAssertEqual(first?.code, "2501", "Error code should match the payload")
        XCTAssertEqual(first?.message, "Document b4bd3e80-7bd1-11e4-95ab-000000000000 does not exist")
        XCTAssertNil(first?.object, "Object should be nil when not provided in payload")
    }

    // Verifies that the message remains the static "Not found" for the .notFound case,
    // and statusCode is nil when no HTTPURLResponse is provided.
    func testNotFoundError_messageIsStaticAndStatusCodeOptional() {
        // Given
        let errorData = loadFile(withName: "notFoundError", ofType: "json")

        // When
        let error = GiniError.notFound(response: nil, data: errorData)

        // Then
        XCTAssertEqual(error.message, "Not found", "Message for notFound should be the static string")
        XCTAssertNil(error.statusCode, "Status code should be nil when response is nil")
        XCTAssertEqual(error.requestId, "req-123456", "Request ID should still be decoded from body")
    }
}
