//
//  UserTests.swift
//
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

class UserTests: XCTestCase {
    
    let user = User(email: "email@test.com", password: "passwordTest")
    
    func testEmail() {
        XCTAssertEqual(user.email, "email@test.com", "email should match")
    }
    
    func testPassword() {
        XCTAssertEqual(user.password, "passwordTest", "password should match")
    }
    
    func testUserEncoded() {
        XCTAssertNoThrow(try JSONEncoder().encode(user),
                         "error thrown while encoding user")
        if let userEncoded = try? JSONEncoder().encode(user),
            let userJSONDictionary = try? (JSONSerialization.jsonObject(with: userEncoded, options: []) as? [String: String]) {
            if userJSONDictionary.contains(where: {$0.key == "email"}) {
                XCTAssertEqual(userJSONDictionary["email"], "email@test.com", "email should match")
            }
        }
        if let userEncoded = try? JSONEncoder().encode(user),
           let userJSONDictionary = try? (JSONSerialization.jsonObject(with: userEncoded, options: []) as? [String: String]) {
            if userJSONDictionary.contains(where: {$0.key == "password"}) {
                XCTAssertEqual(userJSONDictionary["password"], "passwordTest", "password should match")
            }
        }
    }
}
