//
//  PaymentComponentsControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary

final class PaymentComponentsControllerTests: XCTestCase {
    private var giniHealthAPI: GiniHealthAPI!
    private var mockPaymentComponentsController: PaymentComponentsProtocol!
    private let giniHealthConfiguration = GiniHealthConfiguration.shared
    private let versionAPI = 4

    override func setUp() {
        super.setUp()
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock, apiVersion: versionAPI)
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
        XCTAssertNil(mockPaymentComponentsController.selectedPaymentProvider)
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
        let expectedViewModel = PaymentComponentViewModel(paymentProvider: nil, giniHealthConfiguration: giniHealthConfiguration, paymentComponentConfiguration: PaymentComponentConfiguration(isPaymentComponentBranded: true))
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
        XCTAssertTrue(viewController is BanksBottomView)
        guard let bottomSheet = viewController as? BanksBottomView else {
            XCTFail("Error finding correct viewController.")
            return
        }
        XCTAssertNotNil(bottomSheet.viewModel)
    }
    
    func testLoadPaymentReviewScreenFor_Success() {
        // Given
        let documentId = MockSessionManager.payableDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniHealthError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(documentID: documentId, trackingDelegate: nil) { viewController, error in
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
        let documentId = MockSessionManager.missingDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniHealthError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(documentID: documentId, trackingDelegate: nil) { viewController, error in
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
    
    func testPaymentProvidersSorting() {
        let fileName = "notSortedBanks"
        guard let givenPaymentProviders = loadProviders(fileName: fileName) else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }
        
        let expectedPaymentProviders = loadProviders(fileName: "sortedBanks")
        
        let bottomViewModel = BanksBottomViewModel(paymentProviders: givenPaymentProviders, selectedPaymentProvider: nil, urlOpener: URLOpener(MockUIApplication(canOpen: false)))
        
        XCTAssertEqual(bottomViewModel.paymentProviders.count, 11)
        XCTAssertEqual(bottomViewModel.paymentProviders.map { $0.paymentProvider }, expectedPaymentProviders)
    }
}
