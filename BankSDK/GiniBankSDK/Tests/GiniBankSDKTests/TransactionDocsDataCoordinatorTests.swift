//
//  TransactionDocsDataCoordinatorTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK

class TransactionDocsDataPublicProtocolTests: XCTestCase {

    var coordinator: TransactionDocsDataProtocol!
    
    private let mockViewController = UIViewController()
    private let doc1Id = "doc1"
    private let doc2Id = "doc2"
    private let fileName1 = "filename1"
    private let fileName2 = "filename2"
    
    private var doc1: TransactionDoc!
    private var doc2: TransactionDoc!

    override func setUp() {
        super.setUp()
        doc1 = TransactionDoc(documentId: doc1Id, fileName: fileName1, type: .document)
        doc2 = TransactionDoc(documentId: doc2Id, fileName: fileName2, type: .document)
        let coordinator = TransactionDocsDataCoordinator()
        coordinator.transactionDocs = [doc1, doc2]
        self.coordinator = coordinator
    }

    override func tearDown() {
        coordinator = nil
        doc1 = nil
        doc2 = nil
        super.tearDown()
    }

    func test_presentingViewController_shouldSetAndGetCorrectly() {
        coordinator.presentingViewController = mockViewController
        XCTAssertEqual(coordinator.presentingViewController, mockViewController)
    }

    func test_transactionDocIDs_shouldReturnCorrectDocumentIDs() {
        XCTAssertEqual(coordinator.transactionDocIDs, [doc1Id, doc2Id])
    }

    func test_getAlwaysAttachDocsValue_shouldReturnStoredValue() {
        GiniBankUserDefaultsStorage.alwaysAttachDocs = true
        XCTAssertTrue(coordinator.getAlwaysAttachDocsValue())

        GiniBankUserDefaultsStorage.alwaysAttachDocs = false
        XCTAssertFalse(coordinator.getAlwaysAttachDocsValue())
    }

    func test_setAlwaysAttachDocs_shouldUpdateStoredValue() {
        coordinator.setAlwaysAttachDocs(true)
        XCTAssertTrue(GiniBankUserDefaultsStorage.alwaysAttachDocs ?? false)

        coordinator.setAlwaysAttachDocs(false)
        XCTAssertFalse(GiniBankUserDefaultsStorage.alwaysAttachDocs ?? true)
    }
}

class TransactionDocsDataCoordinatorInternalProtocolTests: XCTestCase {

    var coordinator: TransactionDocsDataInternalProtocol!
    
    private let doc1Id = "doc1"
    private let doc2Id = "doc2"
    private let fileName1 = "filename1"
    private let fileName2 = "filename2"
    
    private var doc1: TransactionDoc!
    private var doc2: TransactionDoc!

    override func setUp() {
        super.setUp()
        doc1 = TransactionDoc(documentId: doc1Id, fileName: fileName1, type: .document)
        doc2 = TransactionDoc(documentId: doc2Id, fileName: fileName2, type: .document)
        coordinator = TransactionDocsDataCoordinator()
    }

    override func tearDown() {
        coordinator = nil
        doc1 = nil
        doc2 = nil
        super.tearDown()
    }

    func testInternalTransactionDocsShouldInitialiseEmpty() {
        XCTAssertTrue(coordinator.transactionDocs.isEmpty)
    }

    func testInternalTransactionDocsShouldUpdateCorrectly() {
        coordinator.transactionDocs = [doc1, doc2]
        XCTAssertEqual(coordinator.transactionDocs.count, 2)
        XCTAssertEqual(coordinator.transactionDocs.first?.documentId, doc1Id)
        XCTAssertEqual(coordinator.transactionDocs.last?.documentId, doc2Id)
    }

    func testInternalDeleteTransactionDocShouldRemoveCorrectDocument() {
        coordinator.transactionDocs = [doc1, doc2]
        coordinator.deleteTransactionDoc(with: doc1Id)
        XCTAssertEqual(coordinator.transactionDocs.count, 1)
        XCTAssertEqual(coordinator.transactionDocs.first?.documentId, doc2Id)
    }
}
