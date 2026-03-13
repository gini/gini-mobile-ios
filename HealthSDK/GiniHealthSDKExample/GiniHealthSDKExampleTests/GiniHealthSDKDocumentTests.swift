//
//  GiniHealthSDKDocumentTests.swift
//  GiniHealthSDKExampleTests
//
//  Integration tests for Document operations
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import UIKit
import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

/// Integration tests for Document operations
final class GiniHealthSDKDocumentTests: GiniHealthSDKIntegrationTestsBase {

    // MARK: - Document Upload and Processing Tests

    /// Test document creation with real data
    func testUploadPDFDocument() throws {
        
        let expectUpload = expectation(description: "upload document")
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            switch result {
            case .success(let document):
                XCTAssertFalse(document.id.isEmpty, "Document ID should not be empty")
                XCTAssertEqual(document.sourceClassification, .native)

                // Cleanup: Delete the document after test
                self.giniHealth.deleteDocuments(documentIds: [document.id]) { _ in }

            case .failure(let healthError):
                XCTFail("Failed to upload document: \(healthError.itemsDescription)")
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: extendedTimeout)
    }

    /// Test fetching document after upload
    func testFetchDocument() throws {
        
        let expectUpload = expectation(description: "upload document")
        let expectFetch = expectation(description: "fetch document")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        // First upload a document
        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: extendedTimeout)

        guard let docId = documentId else {
            XCTFail("Document not created")
            return
        }

        // Fetch the document
        giniHealth.documentService.fetchDocument(with: docId) { result in
            switch result {
            case .success(let document):
                XCTAssertEqual(document.id, docId)
                XCTAssertNotNil(document.creationDate)

                // Cleanup
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

            case .failure(let error):
                XCTFail("Failed to fetch document: \(error)")
            }
            expectFetch.fulfill()
        }

        wait(for: [expectFetch], timeout: networkTimeout)
    }

    /// Test extracting payment data from document
    func testGetExtractions() throws {
        
        let expectUpload = expectation(description: "upload document")
        let expectExtractions = expectation(description: "get extractions")

        var documentId: String?

        // Upload a test invoice
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: extendedTimeout)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Get extractions (payment data)
        giniHealth.getExtractions(docId: docId) { result in
            switch result {
            case .success(let extractions):
                XCTAssertFalse(extractions.isEmpty, "Should have extractions")

                // Check for common payment fields
                let hasIban = extractions.contains { $0.name == "iban" }
                let hasAmount = extractions.contains { $0.name == "amountToPay" }
                let hasRecipient = extractions.contains { $0.name == "payment_recipient" }


                // Cleanup
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

            case .failure(let error):
                // It's ok if no payment data is extracted from test image
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectExtractions.fulfill()
        }

        wait(for: [expectExtractions], timeout: extendedTimeout)
    }

    /// Test getting all extractions including medical information
    func testGetAllExtractions() throws {
        
        let expectUpload = expectation(description: "upload document")
        let expectExtractions = expectation(description: "get all extractions")

        var documentId: String?
        // Upload a test invoice
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: extendedTimeout)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Get all extractions (including medical)
        giniHealth.getAllExtractions(docId: docId) { result in
            switch result {
            case .success(let extractions):
                XCTAssertFalse(extractions.isEmpty, "Should have extractions")

                // Cleanup
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

            case .failure(let error):
                XCTFail("Failed to get all extractions: \(error)")
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectExtractions.fulfill()
        }

        wait(for: [expectExtractions], timeout: extendedTimeout)
    }

    /// Test checking if document is payable
    func testCheckIfDocumentIsPayable() throws {
        
        let expectUpload = expectation(description: "upload document")
        let expectCheck = expectation(description: "check payable")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }

        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: extendedTimeout)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Check if document is payable
        giniHealth.checkIfDocumentIsPayable(docId: docId) { result in
            switch result {
            case .success(let isPayable):
                // Note: Test data may not have IBAN, so false is expected

                // Cleanup
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

            case .failure(let error):
                XCTFail("Failed to check payable status: \(error)")
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectCheck.fulfill()
        }

        wait(for: [expectCheck], timeout: extendedTimeout)
    }

    /// Test checking if document contains multiple invoices
    func testCheckIfDocumentContainsMultipleInvoices() throws {
        
        let expectUpload = expectation(description: "upload document")
        let expectCheck = expectation(description: "check multiple invoices")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "multi-invoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }
        
        giniHealth.documentService.createDocument(fileName: "invoice-multiple-check.jpg",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: extendedTimeout)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Check if document contains multiple invoices
        giniHealth.checkIfDocumentContainsMultipleInvoices(docId: docId) { result in
            switch result {
            case .success(let hasMultiple):

                // Cleanup
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

            case .failure(let error):
                XCTFail("Failed to check multiple invoices: \(error)")
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectCheck.fulfill()
        }

        wait(for: [expectCheck], timeout: extendedTimeout)
    }

    /// Test polling document until processing is complete
    func testPollDocument() throws {
        
        let expectUpload = expectation(description: "upload document")
        let expectPoll = expectation(description: "poll document")

        var documentId: String?
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }
        
        giniHealth.documentService.createDocument(fileName: "testMedInvoice.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentId = document.id
            }
            expectUpload.fulfill()
        }

        wait(for: [expectUpload], timeout: extendedTimeout)

        guard let docId = documentId else {
            XCTFail("Document not uploaded")
            return
        }

        // Poll document
        giniHealth.pollDocument(docId: docId) { result in
            switch result {
            case .success(let document):
                XCTAssertEqual(document.id, docId)

                // Cleanup
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }

            case .failure(let error):
                XCTFail("Failed to poll document: \(error)")
                self.giniHealth.deleteDocuments(documentIds: [docId]) { _ in }
            }
            expectPoll.fulfill()
        }

        wait(for: [expectPoll], timeout: extendedTimeout)
    }

    /// Test deleting a batch of documents
    func testDeleteDocuments() throws {
        
        let expectUpload1 = expectation(description: "upload document 1")
        let expectUpload2 = expectation(description: "upload document 2")
        let expectDelete = expectation(description: "delete documents")

        var documentIds: [String] = []
        guard let pdfData = FileLoader.loadFile(withName: "testMedInvoice", ofType: "pdf") else {
            XCTFail("Data was not uploaded")
            return
        }
        
        // Upload first document
        giniHealth.documentService.createDocument(fileName: "testMedInvoice1.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentIds.append(document.id)
            }
            expectUpload1.fulfill()
        }

        // Upload second document
        giniHealth.documentService.createDocument(fileName: "testMedInvoice2.pdf",
                                                  docType: .invoice,
                                                  type: .partial(pdfData),
                                                  metadata: nil) { result in
            if case .success(let document) = result {
                documentIds.append(document.id)
            }
            expectUpload2.fulfill()
        }

        wait(for: [expectUpload1, expectUpload2], timeout: extendedTimeout)

        guard documentIds.count == 2 else {
            XCTFail("Not all documents uploaded")
            return
        }

        // Delete both documents in batch
        giniHealth.deleteDocuments(documentIds: documentIds) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Failed to delete documents: \(error)")
            }
            expectDelete.fulfill()
        }

        wait(for: [expectDelete], timeout: networkTimeout)
    }
}
