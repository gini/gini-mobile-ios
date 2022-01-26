//
//  IntegrationTests.swift
//  GiniHealthAPI
//
//  Created by Alpár Szotyori on 18.09.21.
//

import Foundation

import XCTest
@testable import GiniHealthAPILibrary

class IntegrationTests: XCTestCase {
    
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    
    var giniHealthAPILib: GiniHealthAPI!
    var documentService: DefaultDocumentService!
    
    override func setUp() {
        giniHealthAPILib = GiniHealthAPI
               .Builder(client: Client(id: clientId,
                                       secret: clientSecret,
                                       domain: "pay-api-lib-example"))
               .build()
        documentService = giniHealthAPILib.documentService()
    }
    
    func testErrorLogging() {
        let expect = expectation(description: "it logs the error event")
        
        let errorEvent = ErrorEvent(deviceModel: UIDevice.current.model,
                                    osName: UIDevice.current.systemName,
                                    osVersion: UIDevice.current.systemVersion,
                                    captureSdkVersion: "Not available",
                                    apiLibVersion: Bundle(for: GiniHealthAPI.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                                    description: "Error logging integration test",
                                    documentId: nil,
                                    originalRequestId: nil)
        
        documentService.log(errorEvent: errorEvent) { result in
            switch result {
            case .success:
                expect.fulfill()
            case .failure(let error):
                XCTFail(String(describing: error))
            }
        }
        
        wait(for: [expect], timeout: 10)
    }
    
    func testBuildPaymentService() {
        let paymentService = giniHealthAPILib.paymentService()
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
}
