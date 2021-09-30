//
//  RequestTests.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniPayApiLib

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

