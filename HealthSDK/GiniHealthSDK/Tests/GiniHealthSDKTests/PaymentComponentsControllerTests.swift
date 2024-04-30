//
//  PaymentComponentsControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary

final class PaymentComponentsControllerTests: XCTestCase {
    var giniHealthAPI: GiniHealthAPI!
    var mockPaymentComponentsController: PaymentComponentsProtocol!

    override func setUp() {
        super.setUp()
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock)
        let paymentService = PaymentService(sessionManager: sessionManagerMock)
        giniHealthAPI = GiniHealthAPI(documentService: documentService, paymentService: paymentService)
        let giniHealth = GiniHealth(with: giniHealthAPI)
        mockPaymentComponentsController = MockPaymentComponents(giniHealthSDK: giniHealth)
    }

    override func tearDown() {
        giniHealthAPI = nil
        mockPaymentComponentsController = nil
        super.tearDown()
    }
    
    func testLoadPaymentProviders_Success() {
        // When
        mockPaymentComponentsController.loadPaymentProviders()

        // Then
        XCTAssertFalse(mockPaymentComponentsController.isLoading)
        XCTAssertNotNil(mockPaymentComponentsController.selectedPaymentProvider)
    }
    
    func testCheckIfDocumentIsPayable_Success() {
        let expectedResult: Result<Bool, GiniHealthError> = .success(true)
        // When
        var receivedResult: Result<Bool, GiniHealthError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: MockSessionManager.payableDocumentID) { result in
            receivedResult = result
        }

        // Then
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func testCheckIfDocumentIsPayable_NotPayable() {
        let expectedResult: Result<Bool, GiniHealthError> = .success(false)
        // When
        var receivedResult: Result<Bool, GiniHealthError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: MockSessionManager.notPayableDocumentID) { result in
            receivedResult = result
        }

        // Then
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func testCheckIfDocumentIsPayable_Failure() {
        let expectedResult: Result<Bool, GiniHealthError> = .failure(.apiError(.noResponse))
        // When
        var receivedResult: Result<Bool, GiniHealthError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: MockSessionManager.missingDocumentID) { result in
            receivedResult = result
        }

        // Then
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func testPaymentView_ReturnsView() {
        // Given
        let documentId = "123456"
        let expectedViewModel = PaymentComponentViewModel(paymentProvider: nil)
        let expectedView = PaymentComponentView()
        expectedView.viewModel = expectedViewModel

        // When
        let view = mockPaymentComponentsController.paymentView(documentId: documentId)

        // Then
        XCTAssertTrue(view is PaymentComponentView)
        guard let view = view as? PaymentComponentView else {
            XCTFail("Error finding correct view.")
            return
        }
        XCTAssertEqual(view.viewModel?.documentId, documentId)
    }
    
    func testBankSelectionBottomSheet_ReturnsViewController() {
        // When
        let viewController = mockPaymentComponentsController.bankSelectionBottomSheet()

        // Then
        XCTAssertTrue(viewController is BankSelectionBottomSheet)
        guard let bottomSheet = viewController as? BankSelectionBottomSheet else {
            XCTFail("Error finding correct viewController.")
            return
        }
        XCTAssertNotNil(bottomSheet.bottomSheet)
    }
    
    func testLoadPaymentReviewScreenFor_Success() {
        // Given
        let documentID = MockSessionManager.payableDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniHealthError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(documentID: documentID, trackingDelegate: nil) { viewController, error in
            receivedViewController = viewController
            receivedError = error
        }

        // Then
        XCTAssertNil(receivedError)
        XCTAssertNotNil(receivedViewController)
        XCTAssertTrue(receivedViewController is PaymentReviewViewController)
    }
    
    func testLoadPaymentReviewScreenFor_Failure() {
        // Given
        let documentID = MockSessionManager.missingDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniHealthError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(documentID: documentID, trackingDelegate: nil) { viewController, error in
            receivedViewController = viewController
            receivedError = error
        }

        // Then
        XCTAssertNotNil(receivedError)
        XCTAssertNil(receivedViewController)
        XCTAssertEqual(receivedError, .apiError(.noResponse))
    }
    
    func testPaymentInfoViewController_ReturnsCorrectViewController() {
        // When
        let viewController = mockPaymentComponentsController.paymentInfoViewController()

        // Then
        XCTAssertTrue(viewController is PaymentInfoViewController)
        guard let paymentInfoVC = viewController as? PaymentInfoViewController else {
            XCTFail("Error finding correct viewController.")
            return
        }
        XCTAssertNotNil(paymentInfoVC.viewModel)
        guard let paymentInfoViewModel = paymentInfoVC.viewModel else {
            XCTFail("Error finding payment info viewModel.")
            return
        }
        XCTAssertEqual(paymentInfoViewModel.paymentProviders, [])
    }
}
