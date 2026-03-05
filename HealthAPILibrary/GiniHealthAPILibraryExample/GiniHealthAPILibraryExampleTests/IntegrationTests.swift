//
//  IntegrationTests.swift
//  GiniHealthAPILibraryExampleTests
//
//  Integration tests against real Gini Health API
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest
@testable import GiniHealthAPILibrary

class IntegrationTests: XCTestCase {
    
    private var clientId: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_ID"]
        return value?.isEmpty == false ? value : nil
    }
    
    private var clientSecret: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_SECRET"]
        return value?.isEmpty == false ? value : nil
    }
    
    var giniHealthAPILib: GiniHealthAPI!
    var documentService: DefaultDocumentService!
    var paymentService: PaymentService!
    var createdDocuments: [Document] = []
    
    /// Helper to skip tests when credentials are not available
    private func skipIfCredentialsMissing() throws {
        guard clientId != nil, clientSecret != nil else {
            throw XCTSkip("Integration test skipped: CLIENT_ID and CLIENT_SECRET environment variables must be set. Configure them in the test scheme or test plan.")
        }
    }
    
    override func setUp() {
        guard let id = clientId, let secret = clientSecret else {
            return // XCTSkip will be called in each test method
        }
        
        let pinningConfig = [
            "health-api.gini.net": [
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
            ],
            "user.gini.net": [
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
            ],
        ]
        
        giniHealthAPILib = GiniHealthAPI
                .Builder(client: Client(id: id,
                                        secret: secret,
                                        domain: "pay-api-lib-example"),
                         api: .default,
                         userApi: .default,
                         pinningConfig: pinningConfig)
                .build()
        documentService = giniHealthAPILib.documentService()
        paymentService = giniHealthAPILib.paymentService()
    }
    
    override func tearDown() {
        for document in createdDocuments {
            let exp = expectation(description: "Delete")
            documentService.delete(document) { _ in exp.fulfill() }
            wait(for: [exp], timeout: 30)
        }
        createdDocuments.removeAll()
        super.tearDown()
    }
    
    func testBuildPaymentService() throws {
        try skipIfCredentialsMissing()
        let paymentService = giniHealthAPILib.paymentService()
        XCTAssertEqual(paymentService.apiDomain.domainString, "health-api.gini.net")
    }
    
    func testFetchPaymentProviders() throws {
        try skipIfCredentialsMissing()
        let exp = expectation(description: "Fetch providers")
        paymentService.paymentProviders { result in
            switch result {
            case .success(let providers):
                XCTAssertFalse(providers.isEmpty)
                print("✅ Fetched \(providers.count) providers")
            case .failure(let error):
                XCTFail("Failed: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30)
    }
    
    func testCreateDocument() throws {
        try skipIfCredentialsMissing()
        let exp = expectation(description: "Create document")
        let fileName = "test_pdf.pdf"

        // Try to load from test bundle, fallback to generate valid PDF
        let pdfData: Data
        if let bundlePath = Bundle(for: type(of: self)).path(forResource: "test_pdf", ofType: "pdf"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)) {
            pdfData = data
            documentService.createDocument(fileName: fileName,
                                           docType: nil,
                                           type: .partial(pdfData),
                                           metadata: nil) { result in
                switch result {
                case .success(let doc):
                    self.createdDocuments.append(doc)
                    XCTAssertFalse(doc.id.isEmpty)
                    print("✅ Created document: \(doc.id)")
                case .failure(let error):
                    XCTFail("Failed: \(error)")
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 60)
        } else {
            XCTFail("Failed to load a test PDF")
        }
    }
}
