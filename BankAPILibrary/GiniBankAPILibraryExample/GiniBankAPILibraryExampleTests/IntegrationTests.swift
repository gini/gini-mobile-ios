//
//  IntegrationTests.swift
//  GiniBankAPI
//
//  Created by Alpár Szotyori on 18.09.21.
//

import Foundation

import XCTest
@testable import GiniBankAPILibrary

class IntegrationTests: XCTestCase {
    
    // When running from Xcode: update these environment variables in the scheme.
    // Make sure not to commit the credentials if the scheme is shared!
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    
    var giniBankAPILib: GiniBankAPI!
    var documentService: DefaultDocumentService!
    
    override func setUp() {
        giniBankAPILib = GiniBankAPI
               .Builder(client: Client(id: clientId,
                                       secret: clientSecret,
                                       domain: "pay-api-lib-example"))
               .build()
        documentService = giniBankAPILib.documentService()
    }
    
    func testErrorLogging() {
        let expect = expectation(description: "it logs the error event")
        
        let errorEvent = ErrorEvent(deviceModel: UIDevice.current.model,
                                    osName: UIDevice.current.systemName,
                                    osVersion: UIDevice.current.systemVersion,
                                    captureSdkVersion: "Not available",
                                    apiLibVersion: Bundle(for: GiniBankAPI.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
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
        let paymentService = giniBankAPILib.paymentService()
        XCTAssertEqual(paymentService.apiDomain.domainString, "pay-api.gini.net")
    }
    
}
