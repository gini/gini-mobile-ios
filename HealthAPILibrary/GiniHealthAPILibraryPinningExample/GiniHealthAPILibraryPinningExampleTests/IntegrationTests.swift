//
//  IntegrationTests.swift
//  GiniHealthAPI
//
//  Created by Alpár Szotyori on 18.09.21.
//

import Foundation

import XCTest
@testable import GiniHealthAPILibrary
@testable import GiniHealthAPILibraryPinning
@testable import TrustKit

class IntegrationTests: XCTestCase {
    
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
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
    
    var giniHealthAPILib: GiniHealthAPI!
    var documentService: DefaultDocumentService!
    
    override func setUp() {
        let client = Client(id: clientId,
                            secret: clientSecret,
                            domain: "health-api-lib-pinning-example")
        giniHealthAPILib = GiniHealthAPI
               .Builder(client: client, pinningConfig: yourPublicPinningConfig)
               .build()
        documentService = giniHealthAPILib.documentService()
    }
    
    
    func testBuildPaymentService() {
        let paymentService = giniHealthAPILib.paymentService()
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
}
