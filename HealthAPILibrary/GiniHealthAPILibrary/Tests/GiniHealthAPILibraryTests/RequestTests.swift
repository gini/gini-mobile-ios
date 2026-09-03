//
//  RequestTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class RequestTests: XCTestCase {

    let requestParameters = RequestParameters(method: .get,
                                              headers: TestsConfig.acceptHeader)

    func testMethodInitialization() {
        let method: HTTPMethod = .get
        XCTAssertEqual(requestParameters.method, method, "both methods should match")
    }
    
    func testHeadersInitialization() {
        let headers: HTTPHeaders = TestsConfig.acceptHeader
        XCTAssertEqual(requestParameters.headers, headers, "both headers should match")
    }
}

