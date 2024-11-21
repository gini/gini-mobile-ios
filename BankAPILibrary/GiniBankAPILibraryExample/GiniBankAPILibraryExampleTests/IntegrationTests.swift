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
    let paymentRequestID = "a6466506-acf1-4896-94c8-9b398d4e0ee1"
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
    
    func testFetchPaymentRequest(){
        let expect = expectation(description: "it fetches the payment request")

        let paymentService = giniBankAPILib.paymentService()
        paymentService.paymentRequest(id: paymentRequestID) { result in
            switch result {
            case .success(let request):
                XCTAssertEqual(request.iban, "DE13760700120500154000")
                expect.fulfill()
            case .failure(let error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }
    
    func testResolvePaymentRequest(){
        let message = "You can't resolve the previously resolved payment request"
        let expect = expectation(description: message)

        let paymentService = giniBankAPILib.paymentService()
        paymentService.resolvePaymentRequest(id: paymentRequestID, recipient: "Dr. med. Hackler", iban: "DE13760700120500154000", bic: "", amount: "335.50:EUR", purpose: "ReNr AZ356789Z"){ result in
            switch result {
            case .success(let resolvedRequest):
                XCTFail(message)
            case .failure(let error):
                expect.fulfill()
            }
        }
        wait(for: [expect], timeout: 10)
    }
    
    func testPayment(){
        let expect = expectation(description: "it gets the payment")

        let paymentService = giniBankAPILib.paymentService()
        paymentService.payment(id: "a6466506-acf1-4896-94c8-9b398d4e0ee1"){ result in
            switch result {
            case .success(let payment):
                XCTAssertEqual(payment.iban, "DE13760700120500154000")
                expect.fulfill()
            case .failure(let error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expect], timeout: 10)
    }
}
