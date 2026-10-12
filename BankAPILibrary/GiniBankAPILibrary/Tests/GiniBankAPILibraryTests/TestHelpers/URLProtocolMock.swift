//
//  URLProtocolMock.swift
//  GiniBankAPILibraryTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 URLProtocol stub whose per-request behaviour is defined by `handler`.

 Register with an `URLSessionConfiguration`:

     let config = URLSessionConfiguration.ephemeral
     config.protocolClasses = [URLProtocolMock.self]
     URLProtocolMock.handler = { request in
         (URLProtocolMock.makeResponse(for: request, statusCode: 200), Data())
     }

 Ported from the equivalent helper in the sister `GiniHealthAPILibrary`
 test target so the two API libraries can converge on the same pattern.
 */
final class URLProtocolMock: URLProtocol {
    static var handler: ((URLRequest) -> (HTTPURLResponse, Data?))?

    /**
     Optional error injector. When set, takes precedence over `handler` and
     surfaces the returned `Error` via `URLProtocolClient.urlProtocol(_:didFailWithError:)`
     — the same pathway URLSession uses for real network errors like
     `NSURLErrorNotConnectedToInternet`.
     */
    static var errorHandler: ((URLRequest) -> Error)?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let errorHandler = URLProtocolMock.errorHandler {
            client?.urlProtocol(self, didFailWithError: errorHandler(request))
            return
        }
        guard let handler = URLProtocolMock.handler else {
            fatalError("URLProtocolMock.handler is not set.")
        }

        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        /// no-op — nothing to tear down
    }

    // MARK: - Helpers

    /**
     Fallback URL for the rare case where a `URLRequest` arrives without one —
     the returned `HTTPURLResponse` needs a non-optional URL, so we lean on this
     known-good constant instead of force-unwrapping at every call site.
     */
    static let fallbackURL: URL = {
        guard let url = URL(string: "https://user.gini.net") else {
            fatalError("URLProtocolMock.fallbackURL literal is malformed")
        }
        return url
    }()

    /**
     Build an `HTTPURLResponse` with the requested status code — the initializer
     is optional, so callers would otherwise force-unwrap; this helper wraps the
     invariant in one place.
     */
    static func makeResponse(for request: URLRequest,
                             statusCode: Int,
                             headers: [String: String]? = nil) -> HTTPURLResponse {
        let url = request.url ?? fallbackURL
        guard let response = HTTPURLResponse(url: url,
                                             statusCode: statusCode,
                                             httpVersion: nil,
                                             headerFields: headers) else {
            fatalError("Failed to build HTTPURLResponse with status \(statusCode) for \(url)")
        }
        return response
    }
}
