//
//  UserResourceTests.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniPayApiLib

class UserResourceTests: XCTestCase {
    
    let baseUserCenterAPIURLString = "https://user.gini.net"
    let requestParameters = RequestParameters(method: .get,
                                              headers: ["Accept": "application/vnd.gini.v1+json"])
    
    func testTokenResourceWithClientCredentials() {
        let resource = UserResource<Token>(method: .token(grantType: .clientCredentials),
                                           userDomain: .default,
                                           httpMethod: .get)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=client_credentials")
    }
    
    func testTokenResourceWithPassword() {
        let resource = UserResource<Token>(method: .token(grantType: .password),
                                           userDomain: .default,
                                           httpMethod: .get)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=password")
    }
    
    func testUsersResource() {
        let resource = UserResource<Token>(method: .users,
                                           userDomain: .default,
                                           httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/api/users")
    }
    
    func testCustomUserDomain() {
        let resource = UserResource<Token>(method: .users,
                                           userDomain: .custom(domain: "custom.domain.com"),
                                           httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, "https://custom.domain.com/api/users")
    }
    
}
