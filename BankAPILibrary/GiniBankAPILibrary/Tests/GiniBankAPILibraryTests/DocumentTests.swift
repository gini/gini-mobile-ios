//
//  GiniDocumentTests.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class GiniDocumentTests: XCTestCase {
    
    lazy var documentJson: Data = loadFile(withName: "document", ofType: "json")
    lazy var compositeDocumentJson: Data = loadFile(withName: "compositeDocument", ofType: "json")
    lazy var partialDocumentJson: Data = loadFile(withName: "partialDocument", ofType: "json")
    
    lazy var validDocument: Document = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let giniDocument = try? decoder.decode(Document.self, from: documentJson)
        return giniDocument!
    }()
    
    func testDocumentDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.self, from: documentJson))
    }
    
    func testCompositeDocumentDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.self, from: compositeDocumentJson))
    }
    
    func testPartialDocumentDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.self, from: partialDocumentJson))
    }
    
    func testID() {
        XCTAssertEqual(validDocument.id,
                       "626626a0-749f-11e2-bfd6-000000000000",
                       "document ID should match")
    }
    
    func testCreationDate() {
        XCTAssertEqual(validDocument.creationDate.timeIntervalSince1970,
                       1515932941.2839971,
                       "document creationDate should match")
    }
    
    func testName() {
        XCTAssertEqual(validDocument.name, "scanned.jpg", "document name should match")
    }
    
    func testStatus() {
        XCTAssertEqual(validDocument.progress, .completed, "document status should match")
    }
    
    func testOrigin() {
        XCTAssertEqual(validDocument.origin, .upload, "document origin should match")
    }
    
    func testType() {
        XCTAssertEqual(validDocument.sourceClassification, .scanned, "document type should match")
    }
    
    func testPageCount() {
        XCTAssertEqual(validDocument.pageCount, 1, "document pageCount should be 1")
    }
    
    func testPages() {
        XCTAssertEqual(validDocument.pages?.count, validDocument.pageCount,
                       "document pageCount and pages count should match")
        XCTAssertEqual(validDocument.pages?[0].number, 1, "first page number should be 1")
        XCTAssertEqual(validDocument.pages?[0].images.count, 2, "first page images count should be 2")
    }
    
    func testLinks() {
        XCTAssertEqual(validDocument.links.extractions.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/extractions",
                       "document extractions resource should match")
        XCTAssertEqual(validDocument.links.layout.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/layout",
                       "document layout resource should match")
        XCTAssertEqual(validDocument.links.document.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000",
                       "document document resource should match")
        XCTAssertEqual(validDocument.links.processed.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/processed",
                       "document processed resource should match")
    }
    
    func testIncompleteJSONDecoding() {
        let incompleteJSON = loadFile(withName: "incompleteDocument", ofType: "json")
        XCTAssertThrowsError(try JSONDecoder().decode(Document.self, from: incompleteJSON),
                             "document should be nil since one of its properties is missing")
    }
    
    func testInvalidJSONDecoding() {
        let invalidJSON: Data = "invalid json".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Document.self, from: invalidJSON),
                             "document should be nil since it is not a valid JSON")
    }
    
    func testMetadata() {
        let metadata = Document.Metadata.init(branchId: "test-brand",
                                              additionalHeaders: ["additionalTest": "additionalValue"])
        
        XCTAssertEqual(metadata.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey],
                       "test-brand",
                       "branchId header should match")
        XCTAssertEqual(metadata.headers["\(Document.Metadata.headerKeyPrefix)additionalTest"],
                       "additionalValue",
                       "additional header should match")
    }
    func testUploadMetadata() {
        let metadata = Document.UploadMetadata.init(
            giniCaptureVersion: "99.99.99",
            deviceOrientation: "deviceOrientation",
            source: "source",
            importMethod: "import",
            entryPoint: "unit-test",
            osVersion: "ios 99"
        )
        XCTAssertEqual(
            metadata.userComment,
            Document.UploadMetadata.constructComment(
                osVersion: "ios 99",
                giniVersion: "99.99.99",
                contentId: "",
                source: "source",
                entryPoint: "unit-test",
                importMethod: "import",
                deviceOrientation: "deviceOrientation",
                rotation: ""
            )
        )
    }
    func testAddUploadMetadata() {
        var metadata = Document.Metadata()
        let uploadMetadata = Document.UploadMetadata.init(
            giniCaptureVersion: "99.99.99",
            deviceOrientation: "deviceOrientation",
            source: "source",
            importMethod: "import",
            entryPoint: "unit-test",
            osVersion: "ios 99"
        )
        metadata.addUploadMetadata(uploadMetadata)
        XCTAssertEqual(metadata.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey], uploadMetadata.userComment)
    }
    func testInitWithUploadMetadata() {
        let uploadMetadata = Document.UploadMetadata.init(
            giniCaptureVersion: "99.99.99",
            deviceOrientation: "deviceOrientation",
            source: "source",
            importMethod: "import",
            entryPoint: "unit-test",
            osVersion: "ios 99"
        )
        let metadata = Document.Metadata(uploadMetadata: uploadMetadata)
        XCTAssertEqual(metadata.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey], uploadMetadata.userComment)
    }
}

