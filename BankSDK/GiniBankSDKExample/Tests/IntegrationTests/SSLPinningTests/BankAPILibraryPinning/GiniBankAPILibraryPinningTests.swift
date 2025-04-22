//
//  GiniBankAPILibraryPinningTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class GiniBankAPILibraryPinningTests: BaseIntegrationTest {
    let customApiDomain = "custom-api.domain.com"
    let customUserDomain = "custom-user.domain.com"

    private let client = Client(id: "", secret: "", domain: "")

    func testBuildWithCustomApiDomain() {
        let api = GiniSetupHelper.buildBankAPI(client: client, customApiDomain: customApiDomain)
        let documentService = documentService(from: api)
        assertAPIDomain(documentService, expected: customApiDomain)
    }

    func testBuildWithCustomUserDomain() {
        let api = GiniSetupHelper.buildBankAPI(client: client, customUserDomain: customUserDomain)
        let documentService = documentService(from: api)
        assertUserDomain(documentService, expected: customUserDomain)
    }

    func testBuildWithCustomApiAndUserDomain() {
        let api = GiniSetupHelper.buildBankAPI(client: client,
                                               customApiDomain: customApiDomain,
                                               customUserDomain: customUserDomain)
        let documentService = documentService(from: api)
        assertAPIDomain(documentService, expected: customApiDomain)
        assertUserDomain(documentService, expected: customUserDomain)
    }

    func testWithCustomApiDomainAndAlternativeTokenSource() {
        let api = GiniSetupHelper.buildBankAPI(customApiDomain: customApiDomain,
                                               alternativeTokenSource: TokenSource())
        let documentService = documentService(from: api)
        assertAPIDomain(documentService, expected: customApiDomain)
        assertAlternativeTokenSourceExists(documentService)
    }

    private func assertAPIDomain(_ documentService: DefaultDocumentService, expected: String) {
        XCTAssertEqual(documentService.apiDomain.domainString, expected)
    }

    private func assertUserDomain(_ documentService: DefaultDocumentService, expected: String) {
        let sessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, expected)
    }

    private func assertAlternativeTokenSourceExists(_ documentService: DefaultDocumentService) {
        let sessionManager = documentService.sessionManager as! SessionManager
        XCTAssertNotNil(sessionManager.alternativeTokenSource)
    }

    func documentService(from api: GiniBankAPI) -> DefaultDocumentService {
        return api.documentService()
    }

    private class TokenSource: AlternativeTokenSource {
        func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
            // no-op for test
        }
    }
}
