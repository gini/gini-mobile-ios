//
//  UserTests.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniPayApiLib

class UserTests: XCTestCase {
    
    let user = User(email: "email@test.com", password: "passwordTest")
    
    func testEmail() {
        XCTAssertEqual(user.email, "email@test.com", "email should match")
    }
    
    func testPassword() {
        XCTAssertEqual(user.password, "passwordTest", "password should match")
    }
    
    func testUserEncoded() {
        let userEncoded = try? JSONEncoder().encode(user)
        let userEncodedString = String(data: userEncoded!, encoding: .utf8)
        XCTAssertEqual(userEncodedString, "{\"email\":\"email@test.com\",\"password\":\"passwordTest\"}")
    }
}
