// 
//  SessionManagerHandleErrorTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

// MARK: - URLProtocolMock

class URLProtocolMock: URLProtocol {
    static var handler: ((URLRequest) -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.handler else {
            fatalError("Handler is not set.")
        }

        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // This method will remain empty; no implementation is needed.
    }
}

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

    // MARK: - Tests

    func testUserServiceInvalidGrantMapsToUnauthorized() {
        var resource = APIResource<String>(method: .paymentProviders,
                                           apiDomain: .default,
                                           apiVersion: 5,
                                           httpMethod: .get)
        resource.authServiceType = .userService(.bearer)
        let json = loadFile(withName: "invalidGrantError", ofType: "json")

        URLProtocolMock.handler = { request in
            guard let url = request.url ?? URL(string: "https://example.com") else {
                XCTFail("Invalid URL")
                fatalError("Invalid URL in test")
            }
            guard let response = HTTPURLResponse(url: url,
                                                 statusCode: 400,
                                                 httpVersion: nil,
                                                 headerFields: ["Content-Type": "application/json"]) else {
                XCTFail("Failed to create HTTPURLResponse")
                fatalError("Failed to create HTTPURLResponse")
            }
            return (response, json)
        }

        let exp = expectation(description: "Wait for completion")
        sessionManager.data(resource: resource, cancellationToken: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                self.assertError(error, is: .unauthorized)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testUserServiceInvalidClientMapsToUnauthorized() {
        var resource = APIResource<String>(
            method: .paymentProviders,
            apiDomain: .default,
            apiVersion: 5,
            httpMethod: .get)
        resource.authServiceType = .userService(.bearer)

        let json = loadFile(withName: "invalidClientError", ofType: "json")


        URLProtocolMock.handler = { request in
            guard let url = request.url ?? URL(string: "https://example.com") else {
                XCTFail("Invalid URL")
                fatalError("Invalid URL in test")
            }
            guard let response = HTTPURLResponse(url: url,
                                                 statusCode: 401,
                                                 httpVersion: nil,
                                                 headerFields: ["Content-Type": "application/json"]) else {
                XCTFail("Failed to create HTTPURLResponse")
                fatalError("Failed to create HTTPURLResponse")
            }
            return (response, json)
        }

        let exp = expectation(description: "Wait for completion")
        sessionManager.data(resource: resource, cancellationToken: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                self.assertError(error, is: .unauthorized)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testCustomErrorWhenJSONBodyOn4xx() {
        var resource = APIResource<String>(
            method: .paymentProviders,
            apiDomain: .default,
            apiVersion: 5,
            httpMethod: .get)
        resource.authServiceType = .userService(.bearer)

        guard let json = #"{"message":"x"}"#.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }

        URLProtocolMock.handler = { request in
            guard let url = request.url ?? URL(string: "https://example.com") else {
                XCTFail("Invalid URL")
                fatalError("Invalid URL in test")
            }
            guard let response = HTTPURLResponse(url: url,
                                                 statusCode: 422,
                                                 httpVersion: nil,
                                                 headerFields: ["Content-Type": "application/json"]) else {
                XCTFail("Failed to create HTTPURLResponse")
                fatalError("Failed to create HTTPURLResponse")
            }
            return (response, json)
        }

        let exp = expectation(description: "Wait for completion")
        sessionManager.data(resource: resource, cancellationToken: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                self.assertError(error, is: .customError)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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

            guard let data = testCase.body.data(using: .utf8) else {
                XCTFail("Failed to create data for '\(testCase.body)'")
                continue
            }

            URLProtocolMock.handler = { request in
                guard let url = request.url ?? URL(string: "https://example.com") else {
                    XCTFail("Invalid URL")
                    fatalError("Invalid URL in test")
                }
                guard let response = HTTPURLResponse(url: url,
                                                     statusCode: testCase.status,
                                                     httpVersion: nil,
                                                     headerFields: ["Content-Type": "text/plain"]) else {
                    XCTFail("Failed to create HTTPURLResponse")
                    fatalError("Failed to create HTTPURLResponse")
                }
                return (response, data)
            }

            let exp = expectation(description: "Status \(testCase.status) body '\(testCase.body)'")
            sessionManager.data(resource: resource, cancellationToken: nil) { result in
                switch result {
                case .success:
                    XCTFail("Expected failure but got success for status \(testCase.status)")
                case .failure(let error):
                    self.assertError(error, is: testCase.expectedCase)
                }
                exp.fulfill()
            }

            wait(for: [exp], timeout: 1.0)
        }
    }

    func testApiServiceSkipsOAuthSpecialCases() {
        var resource = APIResource<String>(method: .paymentProviders,
                                           apiDomain: .default,
                                           apiVersion: 5,
                                           httpMethod: .get)
        resource.authServiceType = .apiService
        //invalidGrantError

        guard let json = #"{"error":"invalid_grant"}"#.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }

        URLProtocolMock.handler = { request in
            guard let url = request.url ?? URL(string: "https://example.com") else {
                XCTFail("Invalid URL")
                fatalError("Invalid URL in test")
            }
            guard let response = HTTPURLResponse(url: url,
                                                 statusCode: 400,
                                                 httpVersion: nil,
                                                 headerFields: ["Content-Type": "application/json"]) else {
                XCTFail("Failed to create HTTPURLResponse")
                fatalError("Failed to create HTTPURLResponse")
            }
            return (response, json)
        }

        let exp = expectation(description: "Wait for completion")
        sessionManager.data(resource: resource, cancellationToken: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                self.assertError(error, is: .customError)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}

