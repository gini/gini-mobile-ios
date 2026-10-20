//
//  PaymentComponentsControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
import Combine
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
        XCTAssertEqual(receivedResult, expected, "Payable result should match expected value")
    }

    private func assertAndCast<T>(_ value: Any?,
                                   as type: T.Type,
                                   file: StaticString = #file,
                                   line: UInt = #line) throws -> T {
        XCTAssertTrue(value is T, "Expected \(T.self)", file: file, line: line)
        return try XCTUnwrap(value as? T, "Error finding correct view.", file: file, line: line)
    }
    
    func testLoadPaymentProvidersSuccess() {
        // When
        mockPaymentComponentsController.loadPaymentProviders()

        // Then
        XCTAssertFalse(mockPaymentComponentsController.isLoading, "Loading state should be false after providers are loaded")
        XCTAssertNil(mockPaymentComponentsController.selectedPaymentProvider, "Selected payment provider should be nil initially")
    }

    func testCheckIfDocumentIsPayableSuccess() {
        assertPayableResult(docId: MockSessionManager.payableDocumentID, expected: .success(true))
    }

    func testCheckIfDocumentIsPayableNotPayable() {
        assertPayableResult(docId: MockSessionManager.notPayableDocumentID, expected: .success(false))
    }

    func testCheckIfDocumentIsPayableFailure() {
        assertPayableResult(
            docId: MockSessionManager.missingDocumentID,
            expected: .failure(.apiError(GiniError.toGiniHealthSDKError(error: .noResponse)))
        )
    }

    func testPaymentViewReturnsView() throws {
        let view = mockPaymentComponentsController.paymentView()
        let _ = try assertAndCast(view, as: PaymentComponentView.self)
    }

    func testBankSelectionBottomSheetReturnsViewController() throws {
        let viewController = mockPaymentComponentsController.bankSelectionBottomSheet()
        let bottomSheet = try assertAndCast(viewController, as: BanksBottomView.self)
        XCTAssertNotNil(bottomSheet.viewModel, "Bottom sheet view model should not be nil")
    }
    
    func testLoadPaymentReviewScreenForSuccess() {
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
        XCTAssertNil(receivedError, "Error should be nil for a successful payment review screen load")
        XCTAssertNotNil(receivedViewController, "View controller should not be nil for a successful load")
    }
    
    func testPaymentInfoViewControllerReturnsCorrectViewController() throws {
        let viewController = mockPaymentComponentsController.paymentInfoViewController()
        let paymentInfoVC = try assertAndCast(viewController, as: PaymentInfoViewController.self)
        XCTAssertNotNil(paymentInfoVC.viewModel, "Payment info view model should not be nil")
        XCTAssertEqual(paymentInfoVC.viewModel.paymentProviders, [], "Payment providers should be empty initially")
    }
    
    // MARK: - paymentProvidersPublisher

    func testPaymentProvidersPublisherEmitsEmptyOnSubscribe() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)
        var received: [GiniHealthAPILibrary.PaymentProviders] = []
        let cancellable = controller.paymentProvidersPublisher.sink { received.append($0) }

        XCTAssertEqual(received.count, 1,
                       "Subscribe must deliver exactly one replay")
        XCTAssertEqual(received.first, [],
                       "CurrentValueSubject must replay [] before any fetch resolves")
        cancellable.cancel()
    }

    func testPaymentProvidersPublisherDeliversToMultipleSubscribers() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)
        var r1: [GiniHealthAPILibrary.PaymentProviders] = []
        var r2: [GiniHealthAPILibrary.PaymentProviders] = []

        let c1 = controller.paymentProvidersPublisher.sink { r1.append($0) }
        let c2 = controller.paymentProvidersPublisher.sink { r2.append($0) }

        XCTAssertEqual(r1.count, 1, "Subscriber 1 must receive the replay on subscribe")
        XCTAssertEqual(r2.count, 1, "Subscriber 2 must receive the replay on subscribe")
        XCTAssertEqual(r1.first, r2.first,
                       "Both subscribers must observe the same replay value")

        c1.cancel()
        c2.cancel()
    }

    /// Verifies that a live subscriber receives a non-empty value delivered
    /// through the controller's publisher after `loadPaymentProviders` resolves
    /// — not just the `[]` replay. The subscription is kept alive until the
    /// expected emission arrives, so a regression that drops the subject's
    /// `send(...)` after a successful fetch would fail this test.
    func testPaymentProvidersPublisherDeliversNonEmptyValueAfterLoad() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)

        let expectation = expectation(description: "Receives non-empty providers through publisher")
        expectation.assertForOverFulfill = false
        var received: [GiniHealthAPILibrary.PaymentProviders] = []

        let cancellable = controller.paymentProvidersPublisher.sink { value in
            received.append(value)
            if !value.isEmpty { expectation.fulfill() }
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertFalse(received.isEmpty,
                       "Subscriber must observe at least one emission")
        XCTAssertFalse(received.last?.isEmpty ?? true,
                       "The final emission must carry the fetched providers, not the [] replay")
        cancellable.cancel()
    }

    func testPaymentProvidersSorting() {
        let fileName = "notSortedBanks"
        guard let givenPaymentProviders = loadProviders(fileName: fileName) else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }

        let expectedPaymentProviders = loadProviders(fileName: "sortedBanks")

        let bottomViewModel = BanksBottomViewModel(paymentProviders: givenPaymentProviders.map { $0.toHealthPaymentProvider() },
                                                   paymentProvidersPublisher: Just([]).eraseToAnyPublisher(),
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


        XCTAssertEqual(bottomViewModel.paymentProviders.count, 11, "Providers count should be 11")
        XCTAssertEqual(bottomViewModel.paymentProviders.map { PaymentProvider(healthPaymentProvider: $0.paymentProvider) }, expectedPaymentProviders, "Providers should be sorted as expected")
    }
}
