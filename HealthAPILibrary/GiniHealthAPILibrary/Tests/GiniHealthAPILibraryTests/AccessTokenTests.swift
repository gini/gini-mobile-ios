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
        XCTAssertNotNil(validToken.accessToken, "AccessToken should not be nil")
        XCTAssertEqual(validToken.accessToken, "1eb7ca49-d99f-40cb-b86d-8dd689ca2345", "AccessToken value should match")
    }

    func testType() {
        XCTAssertEqual(validToken.type, "bearer", "Token type should be bearer")
    }

    func testTypeOptional() throws {
        let t = try loadToken(fromFixture: "accessTokenResponseWithoutType")
        XCTAssertNil(t.type, "Token type should be nil when not provided")
    }

    func testExpirationDate() {
        XCTAssertNotNil(validToken.expiration, "Expiration date should not be nil")
        XCTAssertTrue(validToken.expiration < Date(timeInterval: 43199, since: Date()), "Expiration should be within the expected time interval")
        XCTAssertTrue(validToken.expiration > Date(), "Expiration should be after the current date")
    }

    func testScope() {
        XCTAssertEqual(validToken.scope, "read", "Scope should be read")
    }

    func testScopeOptionl() throws {
        let t = try loadToken(fromFixture: "accessTokenResponseWithoutScope")
        XCTAssertNil(t.scope, "Scope should be nil when not provided")
    }

    func testTokenCorrectDecoding() {
        XCTAssertNotNil(validToken, "Token should not be nil after successful decoding")
    }

    func testTokenMissingOptionalFieldsDecoding() throws {
        let t = try loadToken(fromFixture: "accessTokenResponseOnlyRequiredParams")
        XCTAssertNotNil(t, "Token should not be nil when only required fields are present")
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

