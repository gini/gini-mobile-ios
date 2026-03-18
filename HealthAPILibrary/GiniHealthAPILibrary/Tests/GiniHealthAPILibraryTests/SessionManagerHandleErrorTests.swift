// 
//  SessionManagerHandleErrorTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

// MARK: - Tests

final class SessionManagerHandleErrorTests: XCTestCase {
    var sessionManager: SessionManager!

    enum ExpectedErrorCase {
        case badRequest
        case unauthorized
        case notFound
        case notAcceptable
        case tooManyRequests
        case customError
        case unknown
    }

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        sessionManager = SessionManager(urlSession: session)
        // Set tokens to bypass login flow
        sessionManager.clientAccessToken = "dummyClientToken"
        sessionManager.userAccessToken = "dummyUserToken"
    }

    override func tearDown() {
        sessionManager = nil
        URLProtocolMock.handler = nil
        super.tearDown()
    }

    private func assertError(_ error: GiniError,
                             is expected: ExpectedErrorCase,
                             message: String = "",
                             file: StaticString = #file,
                             line: UInt = #line) {
        switch (error, expected) {
        case (.badRequest, .badRequest):
            return
        case (.unauthorized, .unauthorized):
            return
        case (.notFound, .notFound):
            return
        case (.notAcceptable, .notAcceptable):
            return
        case (.tooManyRequests, .tooManyRequests):
            return
        case (.customError, .customError):
            return
        case (.unknown, .unknown):
            return
        default:
            XCTFail("Expected \(expected) but got \(error). \(message)", file: file, line: line)
        }
    }

    // MARK: - Helpers

    private func stubResponse(statusCode: Int,
                               body: Data?,
                               contentType: String = "application/json") {
        URLProtocolMock.handler = { request in
            let url = request.url ?? URL(string: "https://example.com")!
            let response = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: ["Content-Type": contentType])!
            return (response, body)
        }
    }

    private func assertDataCallFails<T>(resource: APIResource<T>,
                                        description: String,
                                        expectingError: ExpectedErrorCase,
                                        message: String = "") {
        let exp = expectation(description: description)
        sessionManager.data(resource: resource, cancellationToken: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success. \(message)")
            case .failure(let error):
                self.assertError(error, is: expectingError, message: message)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Tests

    func testUserServiceInvalidGrantMapsToUnauthorized() {
        var resource = APIResource<String>(method: .paymentProviders,
                                           apiDomain: .default,
                                           apiVersion: 5,
                                           httpMethod: .get)
        resource.authServiceType = .userService(.bearer)
        stubResponse(statusCode: 400, body: loadFile(withName: "invalidGrantError", ofType: "json"))
        assertDataCallFails(resource: resource, description: "Wait for completion", expectingError: .unauthorized)
    }

    func testUserServiceInvalidClientMapsToUnauthorized() {
        var resource = APIResource<String>(method: .paymentProviders,
                                           apiDomain: .default,
                                           apiVersion: 5,
                                           httpMethod: .get)
        resource.authServiceType = .userService(.bearer)
        stubResponse(statusCode: 401, body: loadFile(withName: "invalidClientError", ofType: "json"))
        assertDataCallFails(resource: resource, description: "Wait for completion", expectingError: .unauthorized)
    }

    func testCustomErrorWhenJSONBodyOnAnyStatusCode() {
        let jsonStatusCodes = [400, 401, 403, 404, 422, 500]
        for statusCode in jsonStatusCodes {
            var resource = APIResource<String>(method: .paymentProviders,
                                               apiDomain: .default,
                                               apiVersion: 5,
                                               httpMethod: .get)
            resource.authServiceType = .apiService
            let json = #"{"message":"x"}"#.data(using: .utf8)!
            stubResponse(statusCode: statusCode, body: json)
            assertDataCallFails(resource: resource,
                                description: "Status \(statusCode) + JSON → .customError",
                                expectingError: .customError,
                                message: "status \(statusCode) with JSON body should be .customError")
        }
    }

    func testFallbackMappingsNonJSONBodies() {
        struct TestCase {
            let status: Int
            let body: String
            let expectedCase: ExpectedErrorCase
        }
        let testCases: [TestCase] = [
            TestCase(status: 400, body: "plain400", expectedCase: .badRequest),
            TestCase(status: 401, body: "plain401", expectedCase: .unauthorized),
            TestCase(status: 403, body: "plain403", expectedCase: .unauthorized),
            TestCase(status: 404, body: "plain404", expectedCase: .notFound),
            TestCase(status: 406, body: "plain406", expectedCase: .notAcceptable),
            TestCase(status: 429, body: "plain429", expectedCase: .tooManyRequests),
            TestCase(status: 500, body: "plain500", expectedCase: .unknown)
        ]
        for testCase in testCases {
            var resource = APIResource<String>(method: .paymentProviders,
                                               apiDomain: .default,
                                               apiVersion: 5,
                                               httpMethod: .get)
            resource.authServiceType = .userService(.bearer)
            stubResponse(statusCode: testCase.status,
                         body: testCase.body.data(using: .utf8)!,
                         contentType: "text/plain")
            assertDataCallFails(resource: resource,
                                description: "Status \(testCase.status) body '\(testCase.body)'",
                                expectingError: testCase.expectedCase)
        }
    }

    func testApiServiceSkipsOAuthSpecialCases() {
        var resource = APIResource<String>(method: .paymentProviders,
                                           apiDomain: .default,
                                           apiVersion: 5,
                                           httpMethod: .get)
        resource.authServiceType = .apiService
        stubResponse(statusCode: 400, body: #"{"error":"invalid_grant"}"#.data(using: .utf8)!)
        assertDataCallFails(resource: resource, description: "Wait for completion", expectingError: .customError)
    }
}

