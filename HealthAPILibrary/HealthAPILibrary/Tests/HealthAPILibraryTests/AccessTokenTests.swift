//
//  AccessTokenTests.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniPayApiLib

final class AccessTokenTests: XCTestCase {
    
    let token = try? JSONDecoder().decode(Token.self,
                                     from: ("{\"access_token\":\"1eb7ca49-d99f-40cb-b86d-8dd689ca2345\"," +
        "\"token_type\":\"bearer\",\"expires_in\":43199,\"scope\":\"read\"}").data(using: .utf8)!)

    func testValue() {
        XCTAssertEqual(token?.accessToken, "1eb7ca49-d99f-40cb-b86d-8dd689ca2345")
    }
    
    func testType() {
        XCTAssertEqual(token?.type, "bearer")
    }
    
    func testExpirationDate() {
        XCTAssertTrue(token!.expiration < Date(timeInterval: 43199, since: Date()))
        XCTAssertTrue(token!.expiration > Date())
    }
    
    func testScope() {
        XCTAssertEqual(token?.scope, "read")
    }
    
}
