//
//  AccessTokenTests.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class AccessTokenTests: XCTestCase {
    
    func testAccessToken() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "token_type": "bearer",
                             "expires_in": 43199,
                             "scope": "read"
                            }
                          """
        XCTAssertNotNil(token(from: jsonReponse)?.accessToken, "Expected a `accessToken`, but found nil.")
        XCTAssertEqual(token(from: jsonReponse)?.accessToken, "1eb7ca49-d99f-40cb-b86d-8dd689ca2345")
    }

    func testType() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "token_type": "bearer",
                             "expires_in": 43199,
                             "scope": "read"
                            }
                          """
        XCTAssertEqual(token(from: jsonReponse)?.type, "bearer")
    }

    func testTypeOptionl() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "expires_in": 43199,
                             "scope": "read"
                            }
                          """
        let type = token(from: jsonReponse)?.type
        XCTAssertNil(type, "Expected nil, but found \(String(describing: type)).")
    }


    func testExpirationDate() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "token_type": "bearer",
                             "expires_in": 43199,
                             "scope": "read"
                            }
                          """
        XCTAssertNotNil(token(from: jsonReponse)?.expiration, "Expected a `expires_in`, but found nil.")
        XCTAssertTrue(token(from: jsonReponse)!.expiration < Date(timeInterval: 43199, since: Date()))
        XCTAssertTrue(token(from: jsonReponse)!.expiration > Date())
    }

    func testScope() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "token_type": "bearer",
                             "expires_in": 43199,
                             "scope": "read"
                            }
                          """
        XCTAssertEqual(token(from: jsonReponse)?.scope, "read")
    }

    func testScopeOptionl() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "token_type": "bearer",
                             "expires_in": 43199
                            }
                          """
        let scope = token(from: jsonReponse)?.scope
        XCTAssertNil(scope, "Expected nil, but found \(String(describing: scope)).")
    }

    func testTokenCorrectDecoding() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "token_type": "bearer",
                             "expires_in": 43199,
                             "scope": "read"
                            }
                          """
        guard let token = token(from: jsonReponse) else {
            XCTFail("Failed to decode Token response data")
            fatalError()
        }

        XCTAssertNotNil(token, "Expected a `token`, but found nil.")
    }

    func testTokenMissingOptionalFieldsDecoding() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "expires_in": 43199
                            }
                          """
        guard let token = token(from: jsonReponse) else {
            XCTFail("Failed to decode Token response data")
            fatalError()
        }

        XCTAssertNotNil(token, "Expected a `token`, but found nil.")
    }

    func testTokenMissingRequiredFieldsDecoding() {
        let jsonReponse = """
                            {"access_token": "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                             "token_type": "bearer",
                             "scope": "read"
                            }
                          """
        guard let token = token(from: jsonReponse) else {
            XCTAssertNil(token(from: jsonReponse),"Failed to decode Token response data")
            return
        }

        XCTAssertNotNil(token, "Expected a `token`, but found nil.")
    }

    private func token(from mockRespose: String) -> Token? {
        return try? JSONDecoder().decode(Token.self, from: (mockRespose).data(using: .utf8)!)
    }
}
