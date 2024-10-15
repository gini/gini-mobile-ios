//
//  DocumentCreationTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniCaptureSDK

class DocumentCreationTests: BaseIntegrationTest {

    func testValidDocumentCreation() {
        let fileName = "Gini_invoice_example"
        let documentType = "pdf"

        guard let testDocumentData = FileLoader.loadFile(withName: fileName, ofType: documentType) else {
            XCTFail("Error loading valid file: `\(fileName).\(documentType)`")
            return
        }

        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "GiniBankSDKExample"))
        guard let captureDocument = builder.build(with: testDocumentData, fileName: "\(fileName).\(documentType)") else {
            XCTFail("Failed to build capture document with valid file: `\(fileName).\(documentType)`")
            return
        }

        // Additional assertions to verify the document is correct
        XCTAssertNotNil(captureDocument, "Capture document should be created with valid data")
    }
}
