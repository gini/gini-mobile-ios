//
//  GiniBankAPILibraryPinningTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import TrustKit

final class GiniBankAPILibraryPinningTests: XCTestCase {
    private let client = Client(id: "", secret: "", domain: "")
    private let yourPublicPinningConfig = [
        kTSKPinnedDomains: [
            "pay-api.gini.net": [
                kTSKPublicKeyHashes: [
                    // old *.gini.net public key
                    "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                    // new *.gini.net public key, active from around June 2020
                    "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
                ]],
            "user.gini.net": [
                kTSKPublicKeyHashes: [
                    // old *.gini.net public key
                    "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                    // new *.gini.net public key, active from around June 2020
                    "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
                ]],
        ]] as [String: Any]

    private let customApiDomain = "custom-api.domain.com"
    private let customUserDomain = "custom-user.domain.com"

    func testBuildWithCustomApiDomain() {
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: .custom(domain: customApiDomain, tokenSource: nil),
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()

        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, customApiDomain)
    }

    func testBuildWithCustomUserDomain() {
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 userApi: .custom(domain: customUserDomain),
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()

        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, customUserDomain)
    }

    func testBuildWithCustomApiAndUserDomain() {
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: .custom(domain: customApiDomain, tokenSource: nil),
                                                 userApi: .custom(domain: customUserDomain),
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()

        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, customApiDomain)

        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, customUserDomain)
    }

    func testWithCustomApiDomainAndAlternativeTokenSource() {
        let tokenSource = TokenSource()
        let giniBankAPILib = GiniBankAPI.Builder(customApiDomain: customApiDomain,
                                                 alternativeTokenSource: tokenSource,
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()

        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, customApiDomain)

        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertNotNil(sessionManager.alternativeTokenSource)
    }

    private class TokenSource: AlternativeTokenSource {
        func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
            // This method will remain empty; no implementation is needed.
        }
    }
}
