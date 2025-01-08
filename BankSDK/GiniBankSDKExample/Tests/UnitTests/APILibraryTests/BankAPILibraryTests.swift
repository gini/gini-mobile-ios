//
//  BankAPILibraryTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class BankAPILibraryTests: XCTestCase {

    private let client = Client(id: "", secret: "", domain: "")
    private let customDomain = "custom-api.domain.com"
    private let cutomUserDomain = "custom-user.domain.com"

    func testBuildWithCustomApiDomain() {
        let api = APIDomain.custom(domain: customDomain, tokenSource: nil)
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: api,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        XCTAssertEqual(documentService.apiDomain.domainString, customDomain)
    }

    func testBuildWithCustomUserDomain() {
        let userApi = UserDomain.custom(domain: customDomain)
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 userApi: userApi,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        let sessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, cutomUserDomain)
    }

    func testBuildWithCustomApiAndUserDomain() {
        let api = APIDomain.custom(domain: customDomain, tokenSource: nil)
        let userApi = UserDomain.custom(domain: cutomUserDomain)
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: api,
                                                 userApi: userApi,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        XCTAssertEqual(documentService.apiDomain.domainString, customDomain)

        let sessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, cutomUserDomain)
    }

    func testWithCustomApiDomainAndAlternativeTokenSource() {
        let tokenSource = TokenSource()
        let apiWithTokenSource = APIDomain.custom(domain: customDomain, 
                                                  tokenSource: tokenSource)
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: apiWithTokenSource,
                                                 logLevel: .none)
            .build()

        let documentService = giniBankAPILib.documentService() as DefaultDocumentService
        XCTAssertEqual(documentService.apiDomain.domainString, customDomain)

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
