//
//  GiniDocumentTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthAPILibrary

final class GiniDocumentTests: XCTestCase {
    
    let documentJson: Data = loadFile(withName: "document", ofType: "json")
    let compositeDocumentJson: Data = loadFile(withName: "compositeDocument", ofType: "json")
    let partialDocumentJson: Data = loadFile(withName: "partialDocument", ofType: "json")
    let documentWithoutExpirationDateJson: Data = loadFile(withName: "documentWithoutExpirationDate", ofType: "json")

    lazy var validDocument: Document = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard let giniDocument = try? decoder.decode(Document.self, from: documentJson) else {
            fatalError("Failed to decode valid document JSON")
        }
        return giniDocument
    }()
    
    func testDocumentDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.self, from: documentJson), "Document should be decoded without error")
    }
    
    func testCompositeDocumentDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.self, from: compositeDocumentJson), "Composite document should be decoded without error")
    }
    
    func testPartialDocumentDecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.self, from: partialDocumentJson), "Partial document should be decoded without error")
    }
    
    func testIDDecoding() {
        XCTAssertEqual(validDocument.id,
                       "626626a0-749f-11e2-bfd6-000000000000",
                       "Document ID should match")
    }
    
    func testCreationDateDecoding() {
        XCTAssertEqual(validDocument.creationDate.timeIntervalSince1970,
                       1515932941.2839971,
                       "Document creationDate should match")
    }

    func testExpirationDateDecoding() {
        XCTAssertEqual(validDocument.expirationDate?.timeIntervalSince1970,
                       1515932941.2839971,
                       "Document expirationDate should match")
    }

    func testExpirationDateMissing() {
        lazy var documentWithoutExpirationDate: Document = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard let giniDocument = try? decoder.decode(Document.self, from: documentWithoutExpirationDateJson) else {
                fatalError("Failed to decode document JSON without expiration date")}
            return giniDocument
        }()
        XCTAssertNil(documentWithoutExpirationDate.expirationDate,
                     "Document expirationDate should be nil")
    }


    func testNameDecoding() {
        XCTAssertEqual(validDocument.name, "scanned.jpg", "Document name should match")
    }
    
    func testStatusDecoding() {
        XCTAssertEqual(validDocument.progress, .completed, "Document status should match")
    }
    
    func testOriginDecoding() {
        XCTAssertEqual(validDocument.origin, .upload, "Document origin should match")
    }
    
    func testTypeDecoding() {
        XCTAssertEqual(validDocument.sourceClassification, .scanned, "Document type should match")
    }
    
    func testPageCountDecoding() {
        XCTAssertEqual(validDocument.pageCount, 1, "Document pageCount should be 1")
    }
    
    func testPagesDecoding() {
        XCTAssertEqual(validDocument.pages?.count, validDocument.pageCount,
                       "Document pageCount and pages count should match")
        XCTAssertEqual(validDocument.pages?[0].number, 1, "First page number should be 1")
        XCTAssertEqual(validDocument.pages?[0].images.count, 2, "First page images count should be 2")
    }
    
    func testLinksDecoding() {
        XCTAssertEqual(validDocument.links.extractions.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/extractions",
                       "Document extractions resource should match")
        XCTAssertEqual(validDocument.links.layout.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/layout",
                       "Document layout resource should match")
        XCTAssertEqual(validDocument.links.document.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000",
                       "Document document resource should match")
        XCTAssertEqual(validDocument.links.processed.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/processed",
                       "Document processed resource should match")
    }
    
    func testIncompleteJSONDecoding() {
        let incompleteJSON = loadFile(withName: "incompleteDocument", ofType: "json")
        XCTAssertThrowsError(try JSONDecoder().decode(Document.self, from: incompleteJSON),
                             "Document should be nil since one of its properties is missing")
    }
    
    func testInvalidJSONDecoding() {
        let invalidJSON = Data("invalid json".utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Document.self, from: invalidJSON),
                             "Document should be nil since it is not a valid JSON")
    }
    
    func testMetadataDecoding() {
        let metadata = Document.Metadata.init(branchId: "test-brand",
                                              additionalHeaders: ["additionalTest": "additionalValue"])
        
        XCTAssertEqual(metadata.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey],
                       "test-brand",
                       "BranchId header should match")
        XCTAssertEqual(metadata.headers["\(Document.Metadata.headerKeyPrefix)additionalTest"],
                       "additionalValue",
                       "Additional header should match")
    }
    
}

