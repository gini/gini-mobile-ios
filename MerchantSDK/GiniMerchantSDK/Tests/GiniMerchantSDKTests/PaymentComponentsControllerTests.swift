//
//  PaymentComponentsControllerTests.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniUtilites
@testable import GiniMerchantSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

final class PaymentComponentsControllerTests: XCTestCase {
    private var giniHealthAPI: GiniHealthAPI!
    private var giniMerchant: GiniMerchant!
    private var mockPaymentComponentsController: PaymentComponentsProtocol!
    private let giniMerchantConfiguration = GiniMerchantConfiguration.shared
    private let versionAPI = 1

    override func setUp() {
        super.setUp()
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock, apiDomain: .merchant, apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock, apiDomain: .merchant, apiVersion: versionAPI)
        giniHealthAPI = GiniHealthAPI(documentService: documentService,
                                      paymentService: paymentService,
                                      clientConfigurationService: nil)
        giniMerchant = GiniMerchant(giniApiLib: giniHealthAPI)
        mockPaymentComponentsController = MockPaymentComponents(giniMerchant: giniMerchant)
    }

    override func tearDown() {
        giniHealthAPI = nil
        giniMerchant = nil
        mockPaymentComponentsController = nil
        super.tearDown()
    }
    
    func testLoadPaymentProvidersSuccess() {
        // When
        mockPaymentComponentsController.loadPaymentProviders()

        // Then
        XCTAssertFalse(mockPaymentComponentsController.isLoading)
        XCTAssertNil(mockPaymentComponentsController.selectedPaymentProvider)
    }
    
    func testCheckIfDocumentIsPayableSuccess() {
        let expectedResult: Result<Bool, GiniMerchantError> = .success(true)
        // When
        var receivedResult: Result<Bool, GiniMerchantError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: MockSessionManager.payableDocumentID) { result in
            receivedResult = result
        }

        // Then
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func testCheckIfDocumentIsPayableNotPayable() {
        let expectedResult: Result<Bool, GiniMerchantError> = .success(false)
        // When
        var receivedResult: Result<Bool, GiniMerchantError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: MockSessionManager.notPayableDocumentID) { result in
            receivedResult = result
        }

        // Then
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func testCheckIfDocumentIsPayableFailure() {
        let expectedResult: Result<Bool, GiniMerchantError> = .failure(.apiError(GiniError.decorator(.noResponse)))
        // When
        var receivedResult: Result<Bool, GiniMerchantError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: MockSessionManager.missingDocumentID) { result in
            receivedResult = result
        }

        // Then
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func testPaymentViewReturnsView() {
        // Given
        let documentId = "123456"
        let expectedViewModel = PaymentComponentViewModel(paymentProvider: nil,
                                                          primaryButtonConfiguration: giniMerchant.primaryButtonConfiguration,
                                                          secondaryButtonConfiguration: giniMerchant.secondaryButtonConfiguration,
                                                          configuration: giniMerchant.paymentComponentsConfiguration,
                                                          strings: giniMerchant.paymentComponentsStrings,
                                                          poweredByGiniConfiguration: giniMerchant.poweredByGiniConfiguration,
                                                          poweredByGiniStrings: giniMerchant.poweredByGiniStrings,
                                                          moreInformationConfiguration: giniMerchant.moreInformationConfiguration,
                                                          moreInformationStrings: giniMerchant.moreInformationStrings,
                                                          minimumButtonsHeight: giniMerchant.paymentComponentButtonsHeight, 
                                                          paymentComponentConfiguration: giniMerchant.paymentComponentConfiguration,
                                                          clientConfiguration: nil)
        expectedViewModel.documentId = documentId
        let expectedView = PaymentComponentView(viewModel: expectedViewModel)

        // When
        let view = mockPaymentComponentsController.paymentView(documentId: documentId)

        // Then
        XCTAssertTrue(view is PaymentComponentView)
        guard let view = view as? PaymentComponentView else {
            XCTFail("Error finding correct view.")
            return
        }
        XCTAssertEqual(view.viewModel.documentId, expectedView.viewModel.documentId)
    }
    
    func testBankSelectionBottomSheetReturnsViewController() {
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
    
    func testLoadPaymentReviewScreenForSuccess() {
        // Given
        let documentId = MockSessionManager.payableDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniMerchantError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(documentID: documentId, paymentInfo: nil, trackingDelegate: nil) { viewController, error in
            receivedViewController = viewController
            receivedError = error
        }

        // Then
        XCTAssertNil(receivedError)
        XCTAssertNotNil(receivedViewController)
    }
    
    func testLoadPaymentReviewScreenForFailure() {
        // Given
        let documentId = MockSessionManager.missingDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniMerchantError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(documentID: documentId, paymentInfo: nil, trackingDelegate: nil) { viewController, error in
            receivedViewController = viewController
            receivedError = error
        }

        // Then
        XCTAssertNotNil(receivedError)
        XCTAssertNil(receivedViewController)
        XCTAssertEqual(receivedError, .apiError(GiniError.decorator(.noResponse)))
    }
    
    func testPaymentInfoViewControllerReturnsCorrectViewController() {
        // When
        let viewController = mockPaymentComponentsController.paymentInfoViewController()

        // Then
        XCTAssertTrue(viewController is PaymentInfoViewController)
        guard let paymentInfoVC = viewController as? PaymentInfoViewController else {
            XCTFail("Error finding correct viewController.")
            return
        }
        XCTAssertNotNil(paymentInfoVC.viewModel)
        let paymentInfoViewModel = paymentInfoVC.viewModel
        XCTAssertEqual(paymentInfoViewModel.paymentProviders, [])
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
                                                   configuration: giniMerchant.bankSelectionConfiguration,
                                                   strings: giniMerchant.banksBottomStrings,
                                                   poweredByGiniConfiguration: giniMerchant.poweredByGiniConfiguration,
                                                   poweredByGiniStrings: giniMerchant.poweredByGiniStrings,
                                                   moreInformationConfiguration: giniMerchant.moreInformationConfiguration,
                                                   moreInformationStrings: giniMerchant.moreInformationStrings,
                                                   paymentInfoConfiguration: giniMerchant.paymentInfoConfiguration,
                                                   paymentInfoStrings: giniMerchant.paymentInfoStrings,
                                                   urlOpener: URLOpener(MockUIApplication(canOpen: false)),
                                                   clientConfiguration: nil)


        XCTAssertEqual(bottomViewModel.paymentProviders.count, 11)
        XCTAssertEqual(bottomViewModel.paymentProviders.map { PaymentProvider(healthPaymentProvider: $0.paymentProvider) }, expectedPaymentProviders)
    }
}
