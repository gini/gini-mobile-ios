//
//  TransactionDocsDataCoordinatorInternalProtocolTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniBankSDK

class TransactionDocsDataCoordinatorInternalProtocolTests: XCTestCase {

    var coordinator: TransactionDocsDataInternalProtocol!
    private var mockDocs: [TransactionDoc]!

    override func setUp() {
        super.setUp()
        mockDocs = TransactionDoc.createMockDocuments()
        coordinator = TransactionDocsDataCoordinator()
    }

    override func tearDown() {
        coordinator = nil
        mockDocs = nil
        super.tearDown()
    }

    func testInternalTransactionDocsShouldInitialiseEmpty() {
        XCTAssertTrue(coordinator.transactionDocs.isEmpty, "Expected transactionDocs to be empty on initialization")
    }

    func testInternalTransactionDocsShouldUpdateCorrectly() {
        coordinator.transactionDocs = mockDocs
        XCTAssertEqual(coordinator.transactionDocs.count, mockDocs.count, "Expected transactionDocs count to match the mockDocs count after adding documents")
        XCTAssertEqual(coordinator.transactionDocs.first?.documentId, mockDocs.first?.documentId, "Expected first documentId to match the first mock document's ID")
        XCTAssertEqual(coordinator.transactionDocs.last?.documentId, mockDocs.last?.documentId, "Expected last documentId to match the last mock document's ID")
    }

    func testInternalDeleteTransactionDocShouldRemoveCorrectDocument() {
        coordinator.transactionDocs = mockDocs
        coordinator.deleteTransactionDoc(with: mockDocs.first!.documentId)
        XCTAssertEqual(coordinator.transactionDocs.count, mockDocs.count - 1, "Expected transactionDocs count to decrease by one after deleting a document")
        XCTAssertEqual(coordinator.transactionDocs.first?.documentId, mockDocs.last?.documentId, "Expected remaining document to be the second document after deletion")
    }

    func testGetTransactionDocsViewModel() {
        let viewModel = coordinator.getTransactionDocsViewModel()
        XCTAssertNotNil(viewModel, "Expected non-nil viewModel when calling getTransactionDocsViewModel")
        XCTAssertEqual(viewModel?.transactionDocs.count, 0, "Expected viewModel's transactionDocs count to be 0 when no documents are added")
    }
}
