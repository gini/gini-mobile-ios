//
//  AccessTokenTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class AccessTokenTests: XCTestCase {

    private var validToken: Token!

    override func setUp() {
        super.setUp()
        let data = loadFile(withName: "accessTokenResponse", ofType: "json")
        validToken = token(from: data)
        XCTAssertNotNil(validToken, "Failed to load validToken in setUp")
    }

    override func tearDown() {
        validToken = nil
        super.tearDown()
    }

    private func loadToken(fromFixture name: String) throws -> Token {
        let data = loadFile(withName: name, ofType: "json")
        return try XCTUnwrap(token(from: data), "Failed to decode Token from \(name)")
    }

    func testAccessToken() {
        XCTAssertNotNil(validToken.accessToken)
        XCTAssertEqual(validToken.accessToken, "1eb7ca49-d99f-40cb-b86d-8dd689ca2345")
    }

    func testType() {
        XCTAssertEqual(validToken.type, "bearer")
    }

    func testTypeOptional() throws {
        let t = try loadToken(fromFixture: "accessTokenResponseWithoutType")
        XCTAssertNil(t.type)
    }

    func testExpirationDate() {
        XCTAssertNotNil(validToken.expiration)
        XCTAssertTrue(validToken.expiration < Date(timeInterval: 43199, since: Date()))
        XCTAssertTrue(validToken.expiration > Date())
    }

    func testScope() {
        XCTAssertEqual(validToken.scope, "read")
    }

    func testScopeOptionl() throws {
        let t = try loadToken(fromFixture: "accessTokenResponseWithoutScope")
        XCTAssertNil(t.scope)
    }

    func testTokenCorrectDecoding() {
        XCTAssertNotNil(validToken)
    }

    func testTokenMissingOptionalFieldsDecoding() throws {
        let t = try loadToken(fromFixture: "accessTokenResponseOnlyRequiredParams")
        XCTAssertNotNil(t)
    }

    func testTokenMissingRequiredFieldsDecoding() {
        let data = loadFile(withName: "accessTokenResponseMissingExpire", ofType: "json")
        let t = token(from: data)
        XCTAssertNil(t, "Expected decoding to fail due to missing expire_in required field, but it succeeded")
    }

    private func token(from mockRespose: Data) -> Token? {
        return try? JSONDecoder().decode(Token.self, from: mockRespose)
    }
}

