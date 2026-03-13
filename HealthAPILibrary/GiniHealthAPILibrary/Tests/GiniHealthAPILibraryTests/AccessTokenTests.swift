//
//  AccessTokenTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class AccessTokenTests: XCTestCase {
    
    func testAccessToken() {
        let jsonResponse = loadFile(withName: "accessTokenResponse", ofType: "json")
        guard let token = token(from: jsonResponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertNotNil(token.accessToken, "Expected a `accessToken`, but found nil.")
        XCTAssertEqual(token.accessToken, "1eb7ca49-d99f-40cb-b86d-8dd689ca2345")
    }

    func testType() {
        let jsonResponse = loadFile(withName: "accessTokenResponse", ofType: "json")
        guard let token = token(from: jsonResponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertEqual(token.type, "bearer")
    }

    func testTypeOptional() {
        let jsonResponse = loadFile(withName: "accessTokenResponseWithoutType", ofType: "json")
        guard let token = token(from: jsonResponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertNil(token.type, "Expected nil, but found \(String(describing: token.type)).")
    }


    func testExpirationDate() {
        let jsonResponse = loadFile(withName: "accessTokenResponse", ofType: "json")
        guard let token = token(from: jsonResponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertNotNil(token.expiration, "Expected a `expires_in`, but found nil.")
        XCTAssertTrue(token.expiration < Date(timeInterval: 43199, since: Date()))
        XCTAssertTrue(token.expiration > Date())
    }

    func testScope() {
        let jsonResponse = loadFile(withName: "accessTokenResponse", ofType: "json")
        guard let token = token(from: jsonResponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertEqual(token.scope, "read")
    }

    func testScopeOptionl() {
        let jsonResponse = loadFile(withName: "accessTokenResponseWithoutScope", ofType: "json")
        guard let token = token(from: jsonResponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertNil(token.scope, "Expected nil, but found \(String(describing: token.scope)).")
    }

    func testTokenCorrectDecoding() {
        let jsonResponse = loadFile(withName: "accessTokenResponse", ofType: "json")
        guard let token = token(from: jsonResponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertNotNil(token, "Expected a `token`, but found nil.")
    }

    func testTokenMissingOptionalFieldsDecoding() {
        let jsonReponse = loadFile(withName: "accessTokenResponseOnlyRequiredParams", ofType: "json")

        guard let token = token(from: jsonReponse) else {
            XCTFail("Failed to decode Token response data")
            return
        }
        XCTAssertNotNil(token, "Expected a `token`, but found nil.")
    }

    func testTokenMissingRequiredFieldsDecoding() {
        let jsonResponse = loadFile(withName: "accessTokenResponseMissingExpire", ofType: "json")
        let token = token(from: jsonResponse)
        XCTAssertNil(token, "Expected decoding to fail due to missing expire_in required field, but it succeeded")
    }

    private func token(from mockRespose: Data) -> Token? {
        return try? JSONDecoder().decode(Token.self, from: mockRespose)
    }
}

