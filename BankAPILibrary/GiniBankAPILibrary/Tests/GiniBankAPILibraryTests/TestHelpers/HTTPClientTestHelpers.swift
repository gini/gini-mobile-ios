//
//  HTTPClientTestHelpers.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
import Foundation
@testable import GiniBankAPILibrary

// MARK: - MockHTTPClient

final class MockHTTPClient: GiniHTTPClient {
    var dataRequestCalled = false
    var uploadRequestCalled = false
    var downloadRequestCalled = false

    private func makeCancellableTask() -> (task: AnyCancellableTask, wasCancelled: () -> Bool) {
        var cancelCalled = false
        let task = AnyCancellableTask { cancelCalled = true }
        return (task, { cancelCalled })
    }

    @discardableResult
    func dataRequest(_ request: URLRequest,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask {
        dataRequestCalled = true
        let (task, _) = makeCancellableTask()
        completion(nil, nil, nil)
        return task
    }

    @discardableResult
    func uploadRequest(_ request: URLRequest,
                       body: Data,
                       completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask {
        uploadRequestCalled = true
        let (task, _) = makeCancellableTask()
        completion(nil, nil, nil)
        return task
    }

    @discardableResult
    func downloadRequest(_ request: URLRequest,
                         completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> CancellableTask {
        downloadRequestCalled = true
        let (task, _) = makeCancellableTask()
        completion(nil, nil, nil)
        return task
    }
}

// MARK: - StubURLProtocol

/// A URLProtocol stub that immediately returns an empty 200 response.
final class StubURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url,
              let response = HTTPURLResponse(url: url,
                                             statusCode: 200,
                                             httpVersion: nil,
                                             headerFields: nil) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // This method will remain empty; no implementation is needed.
    }
}

/// Creates a URLSession that uses `StubURLProtocol` so no real network calls are made.
func makeStubSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: config)
}
