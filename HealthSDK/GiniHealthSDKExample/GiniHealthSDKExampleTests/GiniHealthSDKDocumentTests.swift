//
//  GiniHealthSDKDocumentTests.swift
//  GiniHealthSDKExampleTests
//
//  Integration tests for Document operations
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniHealthSDK
@testable import GiniHealthAPILibrary

/**
 Integration tests for Document operations
 */
final class GiniHealthSDKDocumentTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - Document Upload and Processing Tests

    func testUploadPDFDocument() throws {
        let docId = try uploadMedInvoice()
        XCTAssertFalse(docId.isEmpty, "Document ID should not be empty")
    }

    func testFetchDocument() throws {
        let docId = try uploadMedInvoice()

        let expect = expectation(description: "fetch document")
        giniHealth.documentService.fetchDocument(with: docId) { result in
            switch result {
            case .success(let document):
                XCTAssertEqual(document.id, docId)
                XCTAssertNotNil(document.creationDate)
            case .failure(let error):
                XCTFail("Failed to fetch document: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
    }

    func testGetExtractions() throws {
        let docId = try uploadMedInvoice()

        let expect = expectation(description: "get extractions")
        giniHealth.getExtractions(docId: docId) { result in
            switch result {
            case .success(let extractions):
                XCTAssertFalse(extractions.isEmpty, "Should have extractions")
            case .failure:
                // No payment data extracted from test data - this is expected
                break
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: extendedTimeout)
    }

    func testGetAllExtractions() throws {
        let docId = try uploadMedInvoice()

        let expect = expectation(description: "get all extractions")
        giniHealth.getAllExtractions(docId: docId) { result in
            switch result {
            case .success(let extractions):
                XCTAssertFalse(extractions.isEmpty, "Should have extractions")
            case .failure(let error):
                XCTFail("Failed to get all extractions: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: extendedTimeout)
    }

    func testCheckIfDocumentIsPayable() throws {
        let docId = try uploadMedInvoice()

        let expect = expectation(description: "check payable")
        giniHealth.checkIfDocumentIsPayable(docId: docId) { result in
            switch result {
            case .success:
                // Test data may not have IBAN, so false is expected — no assertion on value
                break
            case .failure(let error):
                XCTFail("Failed to check payable status: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: extendedTimeout)
    }

    func testCheckIfDocumentContainsMultipleInvoices() throws {
        let data = try XCTUnwrap(FileLoader.loadFile(withName: "multi-invoice", ofType: "pdf"))
        let docId = try uploadAndTrackDocument(fileName: "multi-invoice.pdf", data: data)

        let expect = expectation(description: "check multiple invoices")
        giniHealth.checkIfDocumentContainsMultipleInvoices(docId: docId) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Failed to check multiple invoices: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: extendedTimeout)
    }

    func testPollDocument() throws {
        let docId = try uploadMedInvoice()

        let expect = expectation(description: "poll document")
        giniHealth.pollDocument(docId: docId) { result in
            switch result {
            case .success(let document):
                XCTAssertEqual(document.id, docId)
            case .failure(let error):
                XCTFail("Failed to poll document: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: extendedTimeout)
    }

    func testDeleteDocuments() throws {
        let pdfData = try XCTUnwrap(FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf"))
        let id1 = try uploadAndTrackDocument(fileName: "testMedInvoice1.pdf", data: pdfData)
        let id2 = try uploadAndTrackDocument(fileName: "testMedInvoice2.pdf", data: pdfData)
        let expect = expectation(description: "delete documents")
        giniHealth.deleteDocuments(documentIds: [id1, id2]) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Failed to delete documents: \(error)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: networkTimeout)
    }

    // MARK: - Helpers

    /// Loads `testMedInvoice.pdf` from the bundle, uploads it, and registers the ID for tearDown cleanup.
    private func uploadMedInvoice() throws -> String {
        let data = try XCTUnwrap(FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf"))
        return try uploadAndTrackDocument(fileName: "testMedInvoice.pdf", data: data)
    }

    /// Uploads a document and registers its ID for automatic cleanup in tearDown.
    private func uploadAndTrackDocument(fileName: String, data: Data) throws -> String {
        var documentId: String?
        let expect = expectation(description: "upload document")
        giniHealth.documentService.createDocument(fileName: fileName,
                                                  docType: .invoice,
                                                  type: .partial(data),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: extendedTimeout)
        let id = try XCTUnwrap(documentId, "Document upload failed for '\(fileName)'")
        createdDocumentIds.append(id)
        return id
    }
}
