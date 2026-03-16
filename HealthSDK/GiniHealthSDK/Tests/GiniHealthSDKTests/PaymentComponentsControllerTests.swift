//
//  PaymentComponentsControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class PaymentComponentsControllerTests: XCTestCase {
    private var giniHealthAPI: GiniHealthAPI!
    private var giniHealth: GiniHealth!
    private var mockPaymentComponentsController: PaymentComponentsProtocol!
    private let giniHealthConfiguration = GiniHealthConfiguration.shared
    private let versionAPI = 5

    override func setUp() {
        super.setUp()
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock,
                                                     apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock,
                                            apiVersion: versionAPI)
        giniHealthAPI = GiniHealthAPI(documentService: documentService,
                                      paymentService: paymentService,
                                      clientConfigurationService: nil)
        giniHealth = GiniHealth(giniApiLib: giniHealthAPI)
        mockPaymentComponentsController = MockPaymentComponents(giniHealth: giniHealth)
    }

    override func tearDown() {
        giniHealthAPI = nil
        mockPaymentComponentsController = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func assertPayableResult(docId: String, expected: Result<Bool, GiniHealthError>) {
        var receivedResult: Result<Bool, GiniHealthError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: docId) { result in
            receivedResult = result
        }
        XCTAssertEqual(receivedResult, expected)
    }

    private func assertAndCast<T>(_ value: Any?,
                                   as type: T.Type,
                                   file: StaticString = #file,
                                   line: UInt = #line) throws -> T {
        XCTAssertTrue(value is T, "Expected \(T.self)", file: file, line: line)
        return try XCTUnwrap(value as? T, "Error finding correct view.", file: file, line: line)
    }
    
    func testLoadPaymentProviders_Success() {
        // When
        mockPaymentComponentsController.loadPaymentProviders()

        // Then
        XCTAssertFalse(mockPaymentComponentsController.isLoading)
        XCTAssertNil(mockPaymentComponentsController.selectedPaymentProvider)
    }

    func testCheckIfDocumentIsPayable_Success() {
        assertPayableResult(docId: MockSessionManager.payableDocumentID, expected: .success(true))
    }

    func testCheckIfDocumentIsPayable_NotPayable() {
        assertPayableResult(docId: MockSessionManager.notPayableDocumentID, expected: .success(false))
    }

    func testCheckIfDocumentIsPayable_Failure() {
        assertPayableResult(
            docId: MockSessionManager.missingDocumentID,
            expected: .failure(.apiError(GiniError.toGiniHealthSDKError(error: .noResponse)))
        )
    }

    func testPaymentView_ReturnsView() throws {
        let view = mockPaymentComponentsController.paymentView()
        let _ = try assertAndCast(view, as: PaymentComponentView.self)
    }

    func testBankSelectionBottomSheet_ReturnsViewController() throws {
        let viewController = mockPaymentComponentsController.bankSelectionBottomSheet()
        let bottomSheet = try assertAndCast(viewController, as: BanksBottomView.self)
        XCTAssertNotNil(bottomSheet.viewModel)
    }
    
    func testLoadPaymentReviewScreenFor_Success() {
        // Given
        let documentId = MockSessionManager.payableDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniHealthError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(trackingDelegate: nil,
                                                                   previousPaymentComponentScreenType: nil) { viewController, error in
            receivedViewController = viewController
            receivedError = error
        }

        // Then
        XCTAssertNil(receivedError)
        XCTAssertNotNil(receivedViewController)
    }
    
    func testPaymentInfoViewController_ReturnsCorrectViewController() throws {
        let viewController = mockPaymentComponentsController.paymentInfoViewController()
        let paymentInfoVC = try assertAndCast(viewController, as: PaymentInfoViewController.self)
        XCTAssertNotNil(paymentInfoVC.viewModel)
        XCTAssertEqual(paymentInfoVC.viewModel.paymentProviders, [])
    }
    
    func testPaymentProvidersSorting() {
        let fileName = "notSortedBanks"
        guard let givenPaymentProviders = loadProviders(fileName: fileName) else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }

        let expectedPaymentProviders = loadProviders(fileName: "sortedBanks")

        let bottomViewModel = BanksBottomViewModel(paymentProviders: givenPaymentProviders.map { $0.toHealthPaymentProvider() },
                                                   selectedPaymentProvider: nil,
                                                   configuration: giniHealth.bankSelectionConfiguration,
                                                   strings: giniHealth.banksBottomStrings,
                                                   poweredByGiniConfiguration: giniHealth.poweredByGiniConfiguration,
                                                   poweredByGiniStrings: giniHealth.poweredByGiniStrings,
                                                   moreInformationConfiguration: giniHealth.moreInformationConfiguration,
                                                   moreInformationStrings: giniHealth.moreInformationStrings,
                                                   paymentInfoConfiguration: giniHealth.paymentInfoConfiguration,
                                                   paymentInfoStrings: giniHealth.paymentInfoStrings,
                                                   urlOpener: URLOpener(MockUIApplication(canOpen: false)),
                                                   clientConfiguration: giniHealth.clientConfiguration)


        XCTAssertEqual(bottomViewModel.paymentProviders.count, 11)
        XCTAssertEqual(bottomViewModel.paymentProviders.map { PaymentProvider(healthPaymentProvider: $0.paymentProvider) }, expectedPaymentProviders)
    }
}
