//
//  GiniHealthAPITests.swift
//  GiniHealthAPI-Unit-Tests
//
//  Created by Alpár Szotyori on 03.04.20.
//

import XCTest
@testable import GiniHealthAPILibrary
@testable import GiniHealthAPILibraryPinning
@testable import TrustKit
// swiftlint:disable force_cast

final class GiniHealthAPILibraryPinningTests: XCTestCase {
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
    let client = Client(id: "", secret: "", domain: "")

    func testBuildWithCustomApiDomain() {
        let giniHealthAPILib = GiniHealthAPI.Builder(client: client,
                                                     api: .custom(domain: "custom-api.domain.com", tokenSource: nil),
                                                     pinningConfig: yourPublicPinningConfig,
                                                     logLevel: .none)
            .build()

        let documentService: DefaultDocumentService = giniHealthAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")
    }

    func testBuildWithCustomUserDomain() {
        let giniHealthAPILib = GiniHealthAPI.Builder(client: client,
                                                     userApi: .custom(domain: "custom-user.domain.com"),
                                                     pinningConfig: yourPublicPinningConfig,
                                                     logLevel: .none)
            .build()

        let documentService: DefaultDocumentService = giniHealthAPILib.documentService()
        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }

    func testBuildWithCustomApiAndUserDomain() {
        let giniHealthAPILib = GiniHealthAPI.Builder(client: client,
                                                     api: .custom(domain: "custom-api.domain.com", tokenSource: nil),
                                                     userApi: .custom(domain: "custom-user.domain.com"),
                                                     pinningConfig: yourPublicPinningConfig,
                                                     logLevel: .none)
            .build()

        let documentService: DefaultDocumentService = giniHealthAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")

        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }

    func testWithCustomApiDomainAndAlternativeTokenSource() {
        let tokenSource = TokenSource()
        let giniHealthAPILib = GiniHealthAPI.Builder(customApiDomain: "custom-api.domain.com",
                                                     alternativeTokenSource: tokenSource,
                                                     pinningConfig: yourPublicPinningConfig,
                                                     logLevel: .none)
            .build()

        let documentService: DefaultDocumentService = giniHealthAPILib.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")

        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertNotNil(sessionManager.alternativeTokenSource)
    }

    private class TokenSource: AlternativeTokenSource {
        func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        }
    }
}
