//
//  NetworkingScreenApiCoordinatorTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import XCTest

final class NetworkingScreenApiCoordinatorTests: XCTestCase {
    private var tokenSource: MockTokenSource!
    private var resultsDelegate: MockCaptureResultsDelegate!
    private var configuration: GiniBankConfiguration!
    private var metadata: Document.Metadata!
    private var trackingDelegate: MockTrackingDelegate!

    override func setUp() {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true
        tokenSource = makeTokenSource()
        resultsDelegate = MockCaptureResultsDelegate()
        configuration = GiniBankConfiguration()
        metadata = Document.Metadata(branchId: "branch", bankSDKVersion: GiniBankSDKVersion)
        trackingDelegate = MockTrackingDelegate()
    }

    func testCloseSDK() throws {
        let (coordinator, _) = try makeCoordinatorAndService(fromViewController: true) // so the sdk would start

        XCTAssertEqual(GiniBankNetworkingScreenApiCoordinator.currentCoordinator, coordinator, "The coordinator should be the same")

        GiniBank.closeCurrentSDK()
        XCTAssertNil(GiniBankNetworkingScreenApiCoordinator.currentCoordinator)
        XCTAssertTrue(resultsDelegate.closeCalled, "Should've called delegate for cancelling")
    }

    func testInitWithAlternativeTokenSource() throws {
        let (coordinator, service) = try makeCoordinatorAndService()

        // check domain
        XCTAssertEqual(service.apiDomain.domainString, "pay-api.gini.net", "Service api domain should match our default")

        // check token
        let receivedToken = try XCTUnwrap(
            login(service: service),
            "Should log in successfully"
        )
        XCTAssertEqual(receivedToken, tokenSource.token, "Received token should match the expected token")

        // check for delegates/configs
        XCTAssertNotNil(
            coordinator.resultsDelegate as? MockCaptureResultsDelegate,
            "Coordinator should have correct results delegate instance"
        )
        XCTAssertEqual(coordinator.giniBankConfiguration, configuration, "Coordinator should have correct configuration instance")
        XCTAssertNotNil(
            coordinator.trackingDelegate as? MockTrackingDelegate,
            "Coordinator should have correct tracking delegate instance"
        )
        XCTAssertEqual(coordinator.documentService.metadata?.headers, metadata.headers, "Metadata headers should match")
    }

    func testViewControllerWithAlternativeTokenSource() throws {
        let (coordinator, service) = try makeCoordinatorAndService(fromViewController: true)

        // check domain
        XCTAssertEqual(service.apiDomain.domainString, "pay-api.gini.net", "Service api domain should match our default")

        // check token
        let receivedToken = try XCTUnwrap(
            login(service: service),
            "Should log in successfully"
        )
        XCTAssertEqual(receivedToken, tokenSource.token, "Received token should match the expected token")

        // check for delegates/configs
        XCTAssertNotNil(
            coordinator.resultsDelegate as? MockCaptureResultsDelegate,
            "Coordinator should have correct results delegate instance"
        )
        XCTAssertEqual(coordinator.giniBankConfiguration, configuration, "Coordinator should have correct configuration instance")
        XCTAssertNotNil(
            coordinator.trackingDelegate as? MockTrackingDelegate,
            "Coordinator should have correct tracking delegate instance"
        )
        XCTAssertEqual(coordinator.documentService.metadata?.headers, metadata.headers, "Metadata headers should match")
    }

    // MARK: - determineIfAlreadyPaidHintEnabled Tests

    func testDetermineIfAlreadyPaidHintEnabledAllEnabledDocumentPaidReturnsTrue() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.alreadyPaidHintEnabled = true
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: true)
        let extractionResult = createExtractionResult(paymentState: "paid")

        let result = coordinator.determineIfAlreadyPaidHintEnabled(for: extractionResult)

        XCTAssertTrue(result)
    }

    func testDetermineIfAlreadyPaidHintEnabledGlobalDisabledReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.alreadyPaidHintEnabled = false
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: true)
        let extractionResult = createExtractionResult(paymentState: "paid")

        let result = coordinator.determineIfAlreadyPaidHintEnabled(for: extractionResult)

        XCTAssertFalse(result)
    }

    func testDetermineIfAlreadyPaidHintEnabledDocumentNotPaidReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.alreadyPaidHintEnabled = true
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: true)

        let extractionResult = createExtractionResult(paymentState: "tobepaid")

        let paymentState = coordinator.getDocumentPaymentState(for: extractionResult)
        let result = (paymentState?.rawValue == "paid") && coordinator.determineIfAlreadyPaidHintEnabled(for: extractionResult)

        XCTAssertFalse(result)
    }

    // MARK: - getDocumentPaymentState Tests

    func testGetDocumentPaymentStateWithPaidStatusReturnsPaid() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(paymentState: "paid")

        let result = coordinator.getDocumentPaymentState(for: extractionResult)

        XCTAssertEqual(result, .paid)
    }

    func testGetDocumentPaymentStateWithToBePaidStatusReturnsToBePaid() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(paymentState: "tobepaid")

        let result = coordinator.getDocumentPaymentState(for: extractionResult)

        XCTAssertEqual(result, .toBePaid)
    }

    func testGetDocumentPaymentStateWithNilPaymentStateReturnsNil() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(paymentState: nil)

        let result = coordinator.getDocumentPaymentState(for: extractionResult)

        XCTAssertNil(result)
    }

    func testGetDocumentPaymentStateWithUnknownValueReturnsNil() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(paymentState: "unknown")

        let result = coordinator.getDocumentPaymentState(for: extractionResult)

        XCTAssertNil(result)
    }

    // MARK: - getDocumentPaymentDueDate

    func testGetDocumentPaymentDueDateReturnsCorrectDate() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(paymentDueDate: "2023-01-01")

        let result = coordinator.getDocumentPaymentDueDate(for: extractionResult)

        let expectedDate = Date.date(from: "2023-01-01")

        XCTAssertEqual(result, expectedDate)
    }

    func testGetDocumentPaymentDueDateReturnsNilForIncorrectDateFormat() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(paymentDueDate: "31-11-2025")

        let result = coordinator.getDocumentPaymentDueDate(for: extractionResult)

        XCTAssertNil(result)
    }

    func testGetDocumentPaymentDueDateReturnsNilIfMissing() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(paymentState: "paid")

        let result = coordinator.getDocumentPaymentDueDate(for: extractionResult)

        XCTAssertNil(result)
    }

    // MARK: - determineIfPaymentDueHintEnabled

    func testDetermineIfPaymentDueHintEnabledReturnsTrueWhenEnabled() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.paymentDueHintEnabled = true

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(
            alreadyPaidHintEnabled: false,
            paymentDueHintEnabled: true
        )

        let extractionResult = createExtractionResult(paymentState: "tobepaid")

        let result = coordinator.determineIfPaymentDueHintEnabled(for: extractionResult)

        XCTAssertTrue(result)
    }

    func testDetermineIfPaymentDueHintEnabledReturnsFalseWhenDisabled() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.paymentDueHintEnabled = false

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(
            alreadyPaidHintEnabled: false,
            paymentDueHintEnabled: false
        )

        let extractionResult = createExtractionResult(paymentState: "tobepaid")

        let result = coordinator.determineIfPaymentDueHintEnabled(for: extractionResult)

        XCTAssertFalse(result)
    }

    func testDetermineIfPaymentDueHintGlobalDisabledReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.paymentDueHintEnabled = false

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(
            alreadyPaidHintEnabled: false,
            paymentDueHintEnabled: true
        )

        let extractionResult = createExtractionResult(paymentDueDate: "tobepaid")

        let result = coordinator.determineIfAlreadyPaidHintEnabled(for: extractionResult)

        XCTAssertFalse(result)
    }

    // MARK: - shouldShowReturnAssistant Tests

    func testShouldShowReturnAssistantEnabledWithLineItemsReturnsTrue() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        let lineItems = createMockLineItems()
        let extractionResult = createExtractionResult(lineItems: lineItems)

        let result = coordinator.shouldShowReturnAssistant(for: extractionResult)

        XCTAssertTrue(result)
    }

    func testShouldShowReturnAssistantDisabledWithLineItemsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.returnAssistantEnabled = false
        let lineItems = createMockLineItems()
        let extractionResult = createExtractionResult(lineItems: lineItems)

        let result = coordinator.shouldShowReturnAssistant(for: extractionResult)

        XCTAssertFalse(result)
    }

    func testShouldShowReturnAssistantEnabledWithoutLineItemsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        let extractionResult = createExtractionResult(lineItems: [])

        let result = coordinator.shouldShowReturnAssistant(for: extractionResult)

        XCTAssertFalse(result)
    }

    // MARK: - shouldShowSkonto Tests

    func testShouldShowSkontoEnabledWithDiscountsReturnsTrue() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.skontoEnabled = true
        let skontoDiscounts = createMockSkontoDiscounts()
        let extractionResult = createExtractionResult(skontoDiscounts: skontoDiscounts)

        let result = coordinator.shouldShowSkonto(for: extractionResult)

        XCTAssertTrue(result)
    }

    func testShouldShowSkontoDisabledWithDiscountsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.skontoEnabled = false
        let skontoDiscounts = createMockSkontoDiscounts()
        let extractionResult = createExtractionResult(skontoDiscounts: skontoDiscounts)

        let result = coordinator.shouldShowSkonto(for: extractionResult)

        XCTAssertFalse(result)
    }

    func testShouldShowSkontoEnabledWithoutDiscountsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.skontoEnabled = true
        let extractionResult = createExtractionResult(skontoDiscounts: nil)

        let result = coordinator.shouldShowSkonto(for: extractionResult)

        XCTAssertFalse(result)
    }
}

// MARK: - Helper Methods

private extension NetworkingScreenApiCoordinatorTests {
    func makeTokenSource() -> MockTokenSource {
        MockTokenSource(
            token:
                Token(expiration: .init(),
                      scope: "the_scope",
                      type: "the_type",
                      accessToken: "some_totally_random_gibberish")
        )
    }

    func makeCoordinatorAndService(fromViewController: Bool = false) throws -> (GiniBankNetworkingScreenApiCoordinator,
                                                                                DefaultDocumentService) {
        let coordinator: GiniBankNetworkingScreenApiCoordinator
        if fromViewController {
            let viewController = try XCTUnwrap(
                GiniBank.viewController(withAlternativeTokenSource: tokenSource,
                                        configuration: configuration,
                                        resultsDelegate: resultsDelegate,
                                        documentMetadata: metadata,
                                        trackingDelegate: trackingDelegate) as? ContainerNavigationController,
                "There should be an instance of `ContainerNavigationController`"
            )
            coordinator = try XCTUnwrap(
                viewController.coordinator as? GiniBankNetworkingScreenApiCoordinator,
                "The instance of `ContainerNavigationController` should have a coordinator of type `GiniBankNetworkingScreenApiCoordinator"
            )
        } else {
            coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: tokenSource,
                                                                 resultsDelegate: resultsDelegate,
                                                                 configuration: configuration,
                                                                 documentMetadata: metadata,
                                                                 trackingDelegate: trackingDelegate)
        }
        let documentService = try XCTUnwrap(
            coordinator.documentService as? GiniCaptureSDK.DocumentService,
            "The coordinator should have a document service of type `GiniCaptureSDK.DocumentService"
        )
        let captureNetworkService = try XCTUnwrap(
            documentService.captureNetworkService as? DefaultCaptureNetworkService,
            "The document service should have a capture network service of type `DefaultCaptureNetworkService"
        )

        return (coordinator, captureNetworkService.documentService)
    }

    func login(service: DefaultDocumentService) throws -> Token? {
        let logInExpectation = self.expectation(description: "login")
        var receivedToken: Token?
        service.sessionManager.logIn { result in
            switch result {
            case .success(let token):
                receivedToken = token
                logInExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failure: \(error.localizedDescription)")
            }
        }
        wait(for: [logInExpectation], timeout: 1)
        return receivedToken
    }

    // MARK: - Test Data Creation

    func createExtractionResult(paymentState: String? = nil,
                                paymentDueDate: String? = nil,
                                lineItems: [[Extraction]]? = nil,
                                skontoDiscounts: [[Extraction]]? = nil) -> ExtractionResult {
        var extractions: [Extraction] = []
        
        if let paymentState = paymentState {
            let extraction = Extraction(box: nil,
                                        candidates: nil,
                                        entity: "paymentState",
                                        value: paymentState,
                                        name: "paymentState")
            extractions.append(extraction)
        }
        
        if let paymentDueDate = paymentDueDate {
            let dueDateExtraction = Extraction(box: nil,
                                               candidates: nil,
                                               entity: "paymentDueDate",
                                               value: paymentDueDate,
                                               name: "paymentDueDate")
            extractions.append(dueDateExtraction)
        }
        
        return ExtractionResult(extractions: extractions,
                                lineItems: lineItems,
                                returnReasons: [],
                                skontoDiscounts: skontoDiscounts,
                                candidates: [:])
    }

    func createMockLineItems() -> [[Extraction]] {
        let extraction = Extraction(box: nil,
                                    candidates: nil,
                                    entity: "lineItem",
                                    value: "Test Item",
                                    name: "lineItem")
        return [[extraction]]
    }

    func createMockSkontoDiscounts() -> [[Extraction]] {
        let extraction = Extraction(box: nil,
                                    candidates: nil,
                                    entity: "skontoDiscount",
                                    value: "2.0",
                                    name: "skontoDiscount")
        return [[extraction]]
    }
}

// MARK: - ClientConfiguration Extension

extension ClientConfiguration {
    init(alreadyPaidHintEnabled: Bool, paymentDueHintEnabled: Bool = false) {
        self.init(clientID: "test",
                  userJourneyAnalyticsEnabled: false,
                  skontoEnabled: false,
                  returnAssistantEnabled: false,
                  transactionDocsEnabled: false,
                  instantPaymentEnabled: false,
                  qrCodeEducationEnabled: false,
                  eInvoiceEnabled: false,
                  savePhotosLocallyEnabled: false,
                  alreadyPaidHintEnabled: alreadyPaidHintEnabled,
                  paymentDueHintEnabled: paymentDueHintEnabled)
    }
}
