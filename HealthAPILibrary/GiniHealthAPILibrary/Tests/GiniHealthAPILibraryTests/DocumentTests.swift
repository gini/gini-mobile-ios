//
//  GiniDocumentTests.swift
//
//
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
    
    func testIDDecoding() {
        XCTAssertEqual(validDocument.id,
                       "626626a0-749f-11e2-bfd6-000000000000",
                       "document ID should match")
    }
    
    func testCreationDateDecoding() {
        XCTAssertEqual(validDocument.creationDate.timeIntervalSince1970,
                       1515932941.2839971,
                       "document creationDate should match")
    }

    func testExpirationDateDecoding() {
        XCTAssertEqual(validDocument.expirationDate?.timeIntervalSince1970,
                       1515932941.2839971,
                       "document expirationDate should match")
    }

    func testExpirationDateMissing() {
        lazy var documentWithoutExpirationDate: Document = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let giniDocument = try? decoder.decode(Document.self, from: documentWithoutExpirationDateJson)
            return giniDocument!
        }()
        XCTAssertNil(documentWithoutExpirationDate.expirationDate,
                     "document expirationDate should be nil")
    }


    func testNameDecoding() {
        XCTAssertEqual(validDocument.name, "scanned.jpg", "document name should match")
    }
    
    func testStatusDecoding() {
        XCTAssertEqual(validDocument.progress, .completed, "document status should match")
    }
    
    func testOriginDecoding() {
        XCTAssertEqual(validDocument.origin, .upload, "document origin should match")
    }
    
    func testTypeDecoding() {
        XCTAssertEqual(validDocument.sourceClassification, .scanned, "document type should match")
    }
    
    func testPageCountDecoding() {
        XCTAssertEqual(validDocument.pageCount, 1, "document pageCount should be 1")
    }
    
    func testPagesDecoding() {
        XCTAssertEqual(validDocument.pages?.count, validDocument.pageCount,
                       "document pageCount and pages count should match")
        XCTAssertEqual(validDocument.pages?[0].number, 1, "first page number should be 1")
        XCTAssertEqual(validDocument.pages?[0].images.count, 2, "first page images count should be 2")
    }
    
    func testLinksDecoding() {
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
    
    func testMetadataDecoding() {
        let metadata = Document.Metadata.init(branchId: "test-brand",
                                              additionalHeaders: ["additionalTest": "additionalValue"])
        
        XCTAssertEqual(metadata.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey],
                       "test-brand",
                       "branchId header should match")
        XCTAssertEqual(metadata.headers["\(Document.Metadata.headerKeyPrefix)additionalTest"],
                       "additionalValue",
                       "additional header should match")
    }
    
}

