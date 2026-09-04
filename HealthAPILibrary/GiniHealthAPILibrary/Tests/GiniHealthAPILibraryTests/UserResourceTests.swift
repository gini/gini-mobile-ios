//
//  UserResourceTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

class UserResourceTests: XCTestCase {
    
    let baseUserCenterAPIURLString = "https://user.gini.net"
    let requestParameters = RequestParameters(method: .get,
                                              headers: TestsConfig.acceptHeader)

    func testTokenResourceWithClientCredentials() {
        let resource = UserResource<Token>(method: .token(grantType: .clientCredentials),
                                           userDomain: .default,
                                           httpMethod: .get)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=client_credentials", "Should've built the correct URL for client credentials grant")
    }
    
    func testTokenResourceWithPassword() {
        let resource = UserResource<Token>(method: .token(grantType: .password),
                                           userDomain: .default,
                                           httpMethod: .get)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=password", "URL should match for password grant")
    }
    
    func testUsersResource() {
        let resource = UserResource<Token>(method: .users,
                                           userDomain: .default,
                                           httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/api/users", "URL should match for users resource")
    }
    
    func testCustomUserDomain() {
        let resource = UserResource<Token>(method: .users,
                                           userDomain: .custom(domain: "custom.domain.com"),
                                           httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, "https://custom.domain.com/api/users", "URL should match for custom user domain")
    }
    
}
