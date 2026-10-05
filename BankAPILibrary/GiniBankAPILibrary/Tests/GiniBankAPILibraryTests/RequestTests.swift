//
//  RequestTests.swift
//  GiniExampleTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class RequestTests: XCTestCase {

    let requestParameters = RequestParameters(method: .get,
                                              headers: ["Accept": "application/vnd.gini.v1+json"])
        
    func testMethodInitialization() {
        let method: HTTPMethod = .get
        XCTAssertEqual(requestParameters.method, method, "both methods should match")
    }
    
    func testHeadersInitialization() {
        let headers: HTTPHeaders = ["Accept": "application/vnd.gini.v1+json"]
        XCTAssertEqual(requestParameters.headers, headers, "both headers should match")
    }
}

