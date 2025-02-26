//
//  GiniBankAPILibraryPinningTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary
@testable import TrustKit

final class GiniBankAPILibraryPinningTests: XCTestCase {
    let client = Client(id: "", secret: "", domain: "")
    let yourPublicPinningConfig = [
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

    func testBuildWithCustomApiDomain() {
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: .custom(domain: "custom-api.domain.com", tokenSource: nil),
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()

        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")
    }

    func testBuildWithCustomUserDomain() {
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 userApi: .custom(domain: "custom-user.domain.com"),
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()
        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }

    func testBuildWithCustomApiAndUserDomain() {
        let giniBankAPILib = GiniBankAPI.Builder(client: client,
                                                 api: .custom(domain: "custom-api.domain.com", tokenSource: nil),
                                                 userApi: .custom(domain: "custom-user.domain.com"),
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()
        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")

        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }

    func testWithCustomApiDomainAndAlternativeTokenSource() {
        let tokenSource = TokenSource()
        let giniBankAPILib = GiniBankAPI.Builder(customApiDomain: "custom-api.domain.com",
                                                 alternativeTokenSource: tokenSource,
                                                 pinningConfig: yourPublicPinningConfig,
                                                 logLevel: .none).build()

        let documentService: DefaultDocumentService = giniBankAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")

        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertNotNil(sessionManager.alternativeTokenSource)
    }

    private class TokenSource: AlternativeTokenSource {
        func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
            // This method will remain empty; no implementation is needed.
        }
    }
}
