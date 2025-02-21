//
//  GiniDocumentTests.swift
//  GiniExampleTests
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankAPILibrary

final class GiniDocumentTests: XCTestCase {

    lazy var documentJson: Data = loadFile(withName: "document", ofType: "json")
    lazy var compositeDocumentJson: Data = loadFile(withName: "compositeDocument", ofType: "json")
    lazy var partialDocumentJson: Data = loadFile(withName: "partialDocument", ofType: "json")

    lazy var validDocument: Document = decodeJson(documentJson)

    let uploadMetadata = Document.UploadMetadata(
        giniCaptureVersion: "99.99.99",
        deviceOrientation: "deviceOrientation",
        source: "source",
        importMethod: "import",
        entryPoint: "unit-test",
        osVersion: "ios 99"
    )

    private func decodeJson(_ jsonData: Data) -> Document {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try! decoder.decode(Document.self, from: jsonData)
    }

    func testDocumentDecoding() {
        assertDecodingSucceeds(for: documentJson)
        assertDecodingSucceeds(for: compositeDocumentJson)
        assertDecodingSucceeds(for: partialDocumentJson)
    }

    private func assertDecodingSucceeds(for jsonData: Data) {
        XCTAssertNoThrow(try JSONDecoder().decode(Document.self, from: jsonData))
    }

    func testDocumentProperties() {
        XCTAssertEqual(validDocument.id, "626626a0-749f-11e2-bfd6-000000000000", "document ID should match")
        XCTAssertEqual(validDocument.creationDate.timeIntervalSince1970, 1515932941.2839971, "document creationDate should match")
        XCTAssertEqual(validDocument.name, "scanned.jpg", "document name should match")
        XCTAssertEqual(validDocument.progress, .completed, "document status should match")
        XCTAssertEqual(validDocument.origin, .upload, "document origin should match")
        XCTAssertEqual(validDocument.sourceClassification, .scanned, "document type should match")
        XCTAssertEqual(validDocument.pageCount, 1, "document pageCount should be 1")
    }

    func testPages() {
        XCTAssertEqual(validDocument.pages?.count, validDocument.pageCount, "document pageCount and pages count should match")
        XCTAssertEqual(validDocument.pages?.first?.number, 1, "first page number should be 1")
        XCTAssertEqual(validDocument.pages?.first?.images.count, 2, "first page images count should be 2")
    }

    func testLinks() {
        assertLink(validDocument.links.extractions, "extractions")
        assertLink(validDocument.links.layout, "layout")
        assertLink(validDocument.links.processed, "processed")
    }


    private func assertLink(_ link: URL, _ endpoint: String) {
        let documentLink = "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/"
        XCTAssertEqual(link.absoluteString, documentLink + endpoint,
                       "document \(endpoint) resource should match")
    }

    func testInvalidDecoding() {
        assertDecodingFails(for: loadFile(withName: "incompleteDocument", ofType: "json"))
        assertDecodingFails(for: "invalid json".data(using: .utf8)!)
    }

    private func assertDecodingFails(for jsonData: Data) {
        XCTAssertThrowsError(try JSONDecoder().decode(Document.self, from: jsonData), "document should be nil since it is invalid")
    }

    func testMetadata() {
        let metadata = Document.Metadata(branchId: "test-brand", additionalHeaders: ["additionalTest": "additionalValue"])
        XCTAssertEqual(metadata.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey], "test-brand", "branchId header should match")
        XCTAssertEqual(metadata.headers["\(Document.Metadata.headerKeyPrefix)additionalTest"], "additionalValue", "additional header should match")
    }

    func testUploadMetadata() {
        let expectedComment = Document.UploadMetadata.constructComment(
            osVersion: "ios 99",
            giniVersion: "99.99.99",
            contentId: "",
            source: "source",
            entryPoint: "unit-test",
            importMethod: "import",
            deviceOrientation: "deviceOrientation",
            rotation: ""
        )
        XCTAssertEqual(uploadMetadata.userComment, expectedComment, "Upload metadata(userComment) should match")
    }

    func testMetadataWithUpload() {
        var metadata = Document.Metadata()
        metadata.addUploadMetadata(uploadMetadata)
        assertMetadataValue(metadata, uploadMetadata.userComment)

        let metadataInit = Document.Metadata(uploadMetadata: uploadMetadata)
        assertMetadataValue(metadataInit, uploadMetadata.userComment)
    }

    private func assertMetadataValue(_ metadata: Document.Metadata, _ expectedValue: String) {
        let metadataValue = metadata.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.uploadHeaderKey] ?? ""
        XCTAssertEqual(metadataValue, expectedValue, "userComment should match")
    }
}
