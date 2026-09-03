// 
//  URLProtocolMock.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini. All rights reserved.
//

import Foundation
import XCTest

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
