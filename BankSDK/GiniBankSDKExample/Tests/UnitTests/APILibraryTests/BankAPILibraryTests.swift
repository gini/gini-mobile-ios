//
//  BankAPILibraryTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class BankAPILibraryTests: XCTestCase {

    private let client = Client(id: "", secret: "", domain: "")

    func testBuildWithCustomApiDomain() {
        let api = APIDomain.custom(domain: "custom-api.domain.com", tokenSource: nil)
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: api,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")
    }

    func testBuildWithCustomUserDomain() {
        let userApi = UserDomain.custom(domain: "custom-user.domain.com")
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 userApi: userApi,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        let sessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }

    func testBuildWithCustomApiAndUserDomain() {
        let api = APIDomain.custom(domain: "custom-api.domain.com", tokenSource: nil)
        let userApi = UserDomain.custom(domain: "custom-user.domain.com")
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: api,
                                                 userApi: userApi,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")

        let sessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }

    func testWithCustomApiDomainAndAlternativeTokenSource() {
        let tokenSource = TokenSource()
        let apiWithTokenSource = APIDomain.custom(domain: "custom-api.domain.com", tokenSource: tokenSource)
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: apiWithTokenSource,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")

        let sessionManager = documentService.sessionManager as! SessionManager
        XCTAssertNotNil(sessionManager.alternativeTokenSource)
    }

    // MARK: - Helper Classes

    private class TokenSource: AlternativeTokenSource {
        func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
            // Implementation for token fetching
        }
    }
}
