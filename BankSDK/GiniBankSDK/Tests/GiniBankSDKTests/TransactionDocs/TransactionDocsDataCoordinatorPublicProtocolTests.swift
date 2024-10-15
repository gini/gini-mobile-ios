//
//  TransactionDocsDataCoordinatorTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK

class TransactionDocsDataCoordinatorPublicProtocolTests: XCTestCase {

    var coordinator: TransactionDocsDataProtocol!
    
    private let mockViewController = UIViewController()
    private var mockDocs: [TransactionDoc]!

    override func setUp() {
        super.setUp()
        mockDocs = TransactionDoc.createMockDocuments()
        let transactionDocsDataCoordinator = TransactionDocsDataCoordinator()
        transactionDocsDataCoordinator.transactionDocs = mockDocs
        coordinator = transactionDocsDataCoordinator
    }

    override func tearDown() {
        coordinator = nil
        mockDocs = nil
        super.tearDown()
    }

    func testPresentingViewControllerShouldSetAndGetCorrectly() {
        coordinator.presentingViewController = mockViewController
        XCTAssertEqual(coordinator.presentingViewController,
                       mockViewController,
                       "Expected presentingViewController to be set and retrieved correctly")
    }

    func testTransactionDocIDsShouldReturnCorrectDocumentIDs() {
        let docIDs = mockDocs.map { $0.documentId }
        XCTAssertEqual(coordinator.transactionDocIDs,
                       docIDs,
                       "Expected transactionDocIDs to match the IDs of the mock documents")
    }

    func testGetAlwaysAttachDocsValueShouldReturnStoredValue() {
        GiniBankUserDefaultsStorage.alwaysAttachDocs = true
        XCTAssertTrue(coordinator.getAlwaysAttachDocsValue(),
                      "Expected getAlwaysAttachDocsValue to return true when GiniBankUserDefaultsStorage.alwaysAttachDocs is set to true")

        GiniBankUserDefaultsStorage.alwaysAttachDocs = false
        XCTAssertFalse(coordinator.getAlwaysAttachDocsValue(),
                    "Expected getAlwaysAttachDocsValue to return false when GiniBankUserDefaultsStorage.alwaysAttachDocs is set to false")
    }

    func testSetAlwaysAttachDocsShouldUpdateStoredValue() {
        coordinator.setAlwaysAttachDocs(true)
        XCTAssertTrue(GiniBankUserDefaultsStorage.alwaysAttachDocs ?? false,
                      "Expected GiniBankUserDefaultsStorage.alwaysAttachDocs to be true after setting coordinator.setAlwaysAttachDocs to true")

        coordinator.setAlwaysAttachDocs(false)
        XCTAssertFalse(GiniBankUserDefaultsStorage.alwaysAttachDocs ?? true,
                       "Expected GiniBankUserDefaultsStorage.alwaysAttachDocs to be false after setting coordinator.setAlwaysAttachDocs to false")
    }
}
