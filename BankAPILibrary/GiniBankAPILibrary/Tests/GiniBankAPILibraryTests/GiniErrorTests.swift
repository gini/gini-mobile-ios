//
//  GiniErrorTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class GiniErrorTests: XCTestCase {

    private let mockURL = URL(string: "https://test.com")!
    private let mockData = "mock".data(using: .utf8)!

    func testBadRequestWithoutData() {
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 400, response: response, data: nil)
        XCTAssertEqual(error, .badRequest(response: response, data: nil))
    }

    func testBadRequestWithOtherError() {
        let json = #"{"error": "something_else"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 400, response: response, data: json)
        XCTAssertEqual(error, .badRequest(response: response, data: json))
    }

    func testBadRequestWithInvalidGrant() {
        let json = #"{"error": "invalid_grant"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 400, response: response, data: json)
        XCTAssertEqual(error, .unauthorized(response: response, data: json))
    }

    func testUnauthorized401() {
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 401,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 401, response: response, data: mockData)
        XCTAssertEqual(error, .unauthorized(response: response, data: mockData))
    }

    func testNotFound404() {
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 404,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 404, response: response, data: nil)
        XCTAssertEqual(error, .notFound(response: response, data: nil))
    }

    func testNotAcceptable406() {
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 406,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 406, response: response, data: mockData)
        XCTAssertEqual(error, .notAcceptable(response: response, data: mockData))
    }

    func testTooManyRequests429() {
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 429,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 429, response: response, data: mockData)
        XCTAssertEqual(error, .tooManyRequests(response: response, data: mockData))
    }

    func testClientSideError402() {
        let response = HTTPURLResponse(url: mockURL,
                                       statusCode: 402,
                                       httpVersion: nil,
                                       headerFields: nil)
        let error = GiniError.from(statusCode: 402, response: response, data: mockData)
        XCTAssertEqual(error, .clientSide(response: response, data: mockData))
    }

    func testMaintenance503() {
        let error = GiniError.from(statusCode: 503, response: nil, data: nil)
        XCTAssertEqual(error, .maintenance(errorCode: 503))
    }

    func testOutage500() {
        let error = GiniError.from(statusCode: 500, response: nil, data: nil)
        XCTAssertEqual(error, .outage(errorCode: 500))
    }

    func testServer502() {
        let error = GiniError.from(statusCode: 502, response: nil, data: nil)
        XCTAssertEqual(error, .server(errorCode: 502))
    }

    func testServer504() {
        let error = GiniError.from(statusCode: 504, response: nil, data: nil)
        XCTAssertEqual(error, .server(errorCode: 504))
    }

    func testUnknownStatusCode600() {
        let response = HTTPURLResponse(url: mockURL, statusCode: 600, httpVersion: nil, headerFields: nil)
        let error = GiniError.from(statusCode: 600, response: response, data: mockData)
        XCTAssertEqual(error, .unknown(response: response, data: mockData))
    }
}
