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
    var tokenSource: MockTokenSource!
    var resultsDelegate: MockCaptureResultsDelegate!
    var configuration: GiniBankConfiguration!
    var metadata: Document.Metadata!
    var trackingDelegate: MockTrackingDelegate!

    override func setUp() {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true
        tokenSource = makeTokenSource()
        resultsDelegate = MockCaptureResultsDelegate()
        configuration = GiniBankConfiguration()
        metadata = Document.Metadata(branchId: "branch", bankSDKVersion: GiniBankSDKVersion)
        trackingDelegate = MockTrackingDelegate()
    }

    override func tearDown() {
        GiniBankUserDefaultsStorage.clientConfiguration = nil
        super.tearDown()
    }

    func testCloseSDK() throws {
        let (coordinator, _) = try makeCoordinatorAndService(fromViewController: true) // so the sdk would start

        XCTAssertEqual(GiniBankNetworkingScreenApiCoordinator.currentCoordinator,
                       coordinator, "The coordinator should be the same")

        GiniBank.closeCurrentSDK()
        XCTAssertNil(GiniBankNetworkingScreenApiCoordinator.currentCoordinator)
        XCTAssertTrue(resultsDelegate.closeCalled, "Should've called delegate for cancelling")
    }

    func testInitWithAlternativeTokenSource() throws {
        let (coordinator, service) = try makeCoordinatorAndService()

        // check domain
        XCTAssertEqual(service.apiDomain.domainString,
                       "pay-api.gini.net", "Service api domain should match our default")

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
        XCTAssertEqual(coordinator.giniBankConfiguration, configuration,
                       "Coordinator should have correct configuration instance")
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

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.paymentDueHintEnabled = true

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true)

        let extractionResult = createExtractionResult(paymentState: "tobepaid")

        let result = coordinator.determineIfPaymentDueHintEnabled(for: extractionResult)

        XCTAssertTrue(result)
    }

    func testDetermineIfPaymentDueHintEnabledReturnsFalseWhenDisabled() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.paymentDueHintEnabled = false

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: false)

        let extractionResult = createExtractionResult(paymentState: "tobepaid")

        let result = coordinator.determineIfPaymentDueHintEnabled(for: extractionResult)

        XCTAssertFalse(result)
    }

    func testDetermineIfPaymentDueHintGlobalDisabledReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.paymentDueHintEnabled = false

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true)

        let extractionResult = createExtractionResult(paymentDueDate: "tobepaid")

        let result = coordinator.determineIfAlreadyPaidHintEnabled(for: extractionResult)

        XCTAssertFalse(result)
    }

    // MARK: - isDocumentMarkedAsCreditNote Tests

    func testIsDocumentMarkedAsCreditNoteReturnsTrueForCreditNote() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(businessDocType: "creditnote")

        let result = coordinator.isDocumentMarkedAsCreditNote(from: extractionResult)

        XCTAssertTrue(result, "Should return true when businessDocType is 'creditnote'")
    }

    func testIsDocumentMarkedAsCreditNoteReturnsFalseForNonCreditNote() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(businessDocType: "Invoice")

        let result = coordinator.isDocumentMarkedAsCreditNote(from: extractionResult)

        XCTAssertFalse(result, "Should return false when businessDocType is not 'CreditNote'")
    }

    func testIsDocumentMarkedAsCreditNoteReturnsFalseWhenMissing() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(businessDocType: "")

        let result = coordinator.isDocumentMarkedAsCreditNote(from: extractionResult)

        XCTAssertFalse(result, "Should return false when businessDocType is missing or empty")
    }

    func testIsDocumentMarkedAsCreditNoteIsCaseInsensitive() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(businessDocType: "CreditNote")

        let result = coordinator.isDocumentMarkedAsCreditNote(from: extractionResult)

        XCTAssertTrue(result, "Should return true regardless of case")
    }

    // MARK: - determineIfCreditNoteHintEnabled

    func testDetermineIfCreditNoteHintEnabledReturnsTrueWhenEnabled() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.creditNoteHintEnabled = true

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(creditNoteHintEnabled: true)

        let result = coordinator.determineIfCreditNoteHintEnabled()

        XCTAssertTrue(result, "Should return true when both global and client flags are enabled")
    }

    func testDetermineIfCreditNoteHintEnabledReturnsFalseWhenGlobalDisabled() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.creditNoteHintEnabled = false

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(creditNoteHintEnabled: true)

        let result = coordinator.determineIfCreditNoteHintEnabled()

        XCTAssertFalse(result, "Should return false when global flag is disabled")
    }

    func testDetermineIfCreditNoteHintEnabledReturnsFalseWhenClientDisabled() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.creditNoteHintEnabled = true

        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(creditNoteHintEnabled: false)

        let result = coordinator.determineIfCreditNoteHintEnabled()

        XCTAssertFalse(result, "Should return false when client credit note hint is disabled")
    }

    func testExcludingAmountToPayExtractionResultCreditNote() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(amountToPay: "100.00", businessDocType: "creditnote")

        let result = coordinator.isDocumentMarkedAsCreditNote(from: extractionResult)

        XCTAssertTrue(result, "Should return true when businessDocType is 'creditnote'")

        let endResult = coordinator.excludingAmountToPay(from: extractionResult)

        let hasAmountToPay = endResult.extractions.contains { $0.name == "amountToPay" }
        XCTAssertFalse(hasAmountToPay, "amountToPay should be excluded from extractions")
    }

    // MARK: - shouldShowReturnAssistant Tests

    func testShouldShowReturnAssistantEnabledWithLineItemsReturnsTrue() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        let lineItems = createMockLineItems()
        let extractionResult = createExtractionResult(lineItems: lineItems)

        let result = coordinator.shouldShowReturnAssistant(for: extractionResult)

        XCTAssertTrue(result)
    }

    func testShouldShowReturnAssistantDisabledWithLineItemsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.returnAssistantEnabled = false
        let lineItems = createMockLineItems()
        let extractionResult = createExtractionResult(lineItems: lineItems)

        let result = coordinator.shouldShowReturnAssistant(for: extractionResult)

        XCTAssertFalse(result)
    }

    func testShouldShowReturnAssistantEnabledWithoutLineItemsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        let extractionResult = createExtractionResult(lineItems: [])

        let result = coordinator.shouldShowReturnAssistant(for: extractionResult)

        XCTAssertFalse(result)
    }

    // MARK: - shouldShowSkonto Tests

    func testShouldShowSkontoEnabledWithDiscountsReturnsTrue() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.skontoEnabled = true
        let skontoDiscounts = createMockSkontoDiscounts()
        let extractionResult = createExtractionResult(skontoDiscounts: skontoDiscounts)

        let result = coordinator.shouldShowSkonto(for: extractionResult)

        XCTAssertTrue(result)
    }

    func testShouldShowSkontoDisabledWithDiscountsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.skontoEnabled = false
        let skontoDiscounts = createMockSkontoDiscounts()
        let extractionResult = createExtractionResult(skontoDiscounts: skontoDiscounts)

        let result = coordinator.shouldShowSkonto(for: extractionResult)

        XCTAssertFalse(result)
    }

    func testShouldShowSkontoEnabledWithoutDiscountsReturnsFalse() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.skontoEnabled = true
        let extractionResult = createExtractionResult(skontoDiscounts: nil)

        let result = coordinator.shouldShowSkonto(for: extractionResult)

        XCTAssertFalse(result)
    }

    // MARK: - excludingCompoundExtractions Tests

    func testExcludingCompoundExtractionsRemovesLineItemsAndSkontoDiscounts() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(amountToPay: "100.00",
                                                      businessDocType: "creditnote",
                                                      lineItems: createMockLineItems(),
                                                      skontoDiscounts: createMockSkontoDiscounts())

        let result = coordinator.excludingCompoundExtractions(from: extractionResult)

        XCTAssertNil(result.lineItems, "lineItems should be removed for credit-note documents")
        XCTAssertNil(result.skontoDiscounts, "skontoDiscounts should be removed for credit-note documents")
    }

    func testExcludingCompoundExtractionsKeepsExtractionsAndCandidates() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(amountToPay: "100.00",
                                                      businessDocType: "creditnote",
                                                      lineItems: createMockLineItems(),
                                                      skontoDiscounts: createMockSkontoDiscounts(),
                                                      candidates: createMockCandidates())

        let result = coordinator.excludingCompoundExtractions(from: extractionResult)

        XCTAssertEqual(result.extractions.count,
                       extractionResult.extractions.count,
                       "Flat extractions should not be filtered")
        XCTAssertEqual(result.extractions.first(where: { $0.name == "amountToPay" })?.value,
                       "100.00",
                       "amountToPay should survive compound stripping")
        XCTAssertEqual(result.extractions.first(where: { $0.name == "businessDocType" })?.value,
                       "creditnote",
                       "businessDocType should survive compound stripping")
        XCTAssertEqual(result.candidates["amounts"]?.first?.value,
                       "100.00:EUR",
                       "Candidates should be carried over unchanged")
    }

    func testShouldShowReturnAssistantFalseAfterExcludingCompoundExtractions() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        let extractionResult = createExtractionResult(businessDocType: "creditnote",
                                                      lineItems: createMockLineItems())

        XCTAssertTrue(coordinator.shouldShowReturnAssistant(for: extractionResult),
                      "Precondition: RA gate should be true before stripping")

        let stripped = coordinator.excludingCompoundExtractions(from: extractionResult)

        XCTAssertFalse(coordinator.shouldShowReturnAssistant(for: stripped),
                       "RA gate should be false on a stripped credit-note result")
    }

    func testShouldShowSkontoFalseAfterExcludingCompoundExtractions() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.skontoEnabled = true
        let extractionResult = createExtractionResult(businessDocType: "creditnote",
                                                      skontoDiscounts: createMockSkontoDiscounts())

        XCTAssertTrue(coordinator.shouldShowSkonto(for: extractionResult),
                      "Precondition: Skonto gate should be true before stripping")

        let stripped = coordinator.excludingCompoundExtractions(from: extractionResult)

        XCTAssertFalse(coordinator.shouldShowSkonto(for: stripped),
                       "Skonto gate should be false on a stripped credit-note result")
    }

    func testExcludingAmountToPayOnStrippedResultRemovesAmountToPay() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(amountToPay: "100.00",
                                                      businessDocType: "creditnote",
                                                      lineItems: createMockLineItems(),
                                                      skontoDiscounts: createMockSkontoDiscounts())

        let stripped = coordinator.excludingCompoundExtractions(from: extractionResult)
        let filtered = coordinator.excludingAmountToPay(from: stripped)

        XCTAssertFalse(filtered.extractions.contains { $0.name == "amountToPay" },
                       "amountToPay should be excluded after chaining both helpers")
        XCTAssertEqual(filtered.extractions.first(where: { $0.name == "businessDocType" })?.value,
                       "creditnote",
                       "businessDocType should still be delivered")
        XCTAssertNil(filtered.lineItems, "lineItems should stay removed after amountToPay filtering")
        XCTAssertNil(filtered.skontoDiscounts, "skontoDiscounts should stay removed after amountToPay filtering")
    }

    func testNonCreditNoteResultKeepsCompoundExtractions() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        coordinator.giniBankConfiguration.skontoEnabled = true
        let extractionResult = createExtractionResult(amountToPay: "100.00",
                                                      businessDocType: "invoice",
                                                      lineItems: createMockLineItems(),
                                                      skontoDiscounts: createMockSkontoDiscounts())

        XCTAssertFalse(coordinator.isDocumentMarkedAsCreditNote(from: extractionResult),
                       "An invoice must not be detected as a credit note, so the flow never strips it")
        XCTAssertTrue(coordinator.shouldShowReturnAssistant(for: extractionResult),
                      "A non-credit-note document should keep its Return Assistant eligibility")
        XCTAssertTrue(coordinator.shouldShowSkonto(for: extractionResult),
                      "A non-credit-note document should keep its Skonto eligibility")
    }

    // MARK: - creditNoteDeliveryResult Tests

    func testCreditNoteDeliveryResultStripsCompoundExtractionsAndAmountToPay() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(amountToPay: "100.00",
                                                      businessDocType: "creditnote",
                                                      lineItems: createMockLineItems(),
                                                      skontoDiscounts: createMockSkontoDiscounts())

        let delivered = coordinator.creditNoteDeliveryResult(from: extractionResult)

        XCTAssertNil(delivered.lineItems, "lineItems should be removed from the delivered credit-note result")
        XCTAssertNil(delivered.skontoDiscounts, "skontoDiscounts should be removed from the delivered credit-note result")
        XCTAssertFalse(delivered.extractions.contains { $0.name == "amountToPay" },
                       "amountToPay should be removed from the delivered credit-note result")
    }

    func testCreditNoteDeliveryResultKeepsRemainingFlatExtractionsAndCandidates() throws {
        let (coordinator, _) = try makeCoordinatorAndService()

        let extractionResult = createExtractionResult(amountToPay: "100.00",
                                                      businessDocType: "creditnote",
                                                      lineItems: createMockLineItems(),
                                                      candidates: createMockCandidates())

        let delivered = coordinator.creditNoteDeliveryResult(from: extractionResult)

        XCTAssertEqual(delivered.extractions.first(where: { $0.name == "businessDocType" })?.value,
                       "creditnote",
                       "businessDocType should still be delivered for a credit note")
        XCTAssertEqual(delivered.extractions.count,
                       extractionResult.extractions.count - 1,
                       "Only amountToPay should be filtered from the flat extractions")
        XCTAssertEqual(delivered.candidates["amounts"]?.first?.value,
                       "100.00:EUR",
                       "Candidates should be carried over unchanged")
    }

    /**
     Covers the Wero camera-fallback branch of
     `presentNextScreen(extractionResult:delegate:)` by driving the full
     `didReview → startAnalysisWithReturnAssistant → handleSuccessfulAnalysis
      → presentNextScreen → performWeroFallbackIfNeeded → return` chain
     through the public `GiniCaptureDelegate.didReview` entry point.
     `StubAnalysisCaptureNetworkService` fires the analysis completion with
     an empty extraction set, and the Wero QR page seeded on `pages` makes
     `performWeroFallbackIfNeeded` return `true` so the branch body runs.
     */
    @MainActor
    func testDidReviewWithWeroCandidateFiresCameraFallback() async throws {
        let originalFlag = GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled
        GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = true
        defer { GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = originalFlag }

        let originalMultipage = configuration.multipageEnabled
        configuration.multipageEnabled = true
        defer { configuration.multipageEnabled = originalMultipage }

        let stubService = StubAnalysisCaptureNetworkService(
            extractionResult: ExtractionResult(extractions: [], candidates: [:])
        )
        let coordinator = GiniBankNetworkingScreenApiCoordinator(
            resultsDelegate: resultsDelegate,
            configuration: configuration,
            documentMetadata: metadata,
            trackingDelegate: trackingDelegate,
            captureNetworkService: stubService,
            configurationService: nil
        )

        let weroDocument = GiniQRCodeDocument(scannedString: "https://pay.weropay.eu/pay/v1/token=xyz")
        coordinator.pages = [GiniCapturePage(document: weroDocument)]

        let networkDelegate = MockCaptureNetworkDelegate()
        coordinator.didReview(documents: [weroDocument], networkDelegate: networkDelegate)

        /// Pump the main run loop so the DispatchQueue hops and the
        /// `Task { await handleSuccessfulAnalysis(...) }` all land before
        /// the assertion. Bounded so a hang surfaces as a failed assertion.
        for _ in 0..<40 where networkDelegate.invalidQRMessageCallCount == 0 {
            await Task.yield()
            await MainActor.run {
                RunLoop.current.run(until: Date().addingTimeInterval(0.02))
            }
        }

        XCTAssertEqual(networkDelegate.invalidQRMessageCallCount, 1,
                       "Wero fallback branch inside presentNextScreen must notify the delegate")
    }

    /**
     Confirmed Wero (`weroPaymentQRCodeUrl` in extractions) delivers directly
     via the results callback and bypasses `presentNextScreen`.
     */
    @MainActor
    func testConfirmedWeroResultDeliversDirectlyAndSkipsFeatureFlows() async throws {
        let originalMultipage = configuration.multipageEnabled
        configuration.multipageEnabled = true
        defer { configuration.multipageEnabled = originalMultipage }

        /// TransactionDocs on → regression tripwire for the direct-delivery path.
        let originalTransactionDocs = configuration.transactionDocsEnabled
        configuration.transactionDocsEnabled = true
        defer { configuration.transactionDocsEnabled = originalTransactionDocs }

        let fixtureResult = try loadWeroDeliveryFixture("confirmed_wero_url")
        let weroPayload = try XCTUnwrap(fixtureResult.extractions.first?.value)
        let stubService = StubAnalysisCaptureNetworkService(extractionResult: fixtureResult)
        let coordinator = GiniBankNetworkingScreenApiCoordinator(
            resultsDelegate: resultsDelegate,
            configuration: configuration,
            documentMetadata: metadata,
            trackingDelegate: trackingDelegate,
            captureNetworkService: stubService,
            configurationService: nil
        )

        let weroDocument = GiniQRCodeDocument(scannedString: weroPayload)
        coordinator.pages = [GiniCapturePage(document: weroDocument)]

        let networkDelegate = MockCaptureNetworkDelegate()
        coordinator.didReview(documents: [weroDocument], networkDelegate: networkDelegate)

        /// Pump main until delivery; bounded so a hang surfaces as failed assertion.
        for _ in 0..<40 where resultsDelegate.deliveredResultsCount == 0 {
            await Task.yield()
            await MainActor.run {
                RunLoop.current.run(until: Date().addingTimeInterval(0.02))
            }
        }

        XCTAssertEqual(resultsDelegate.deliveredResultsCount, 1,
                       "Confirmed Wero result must deliver directly through the results callback")
        let delivered = try XCTUnwrap(resultsDelegate.deliveredResults.first)
        XCTAssertEqual(delivered.extractions[QRCodesExtractor.weroPaymentQRCodeUrlKey]?.value,
                       weroPayload,
                       "The delivered Wero URL must match the scanned payload")
        /// URL-only shape (EPS parity): no document, images or line items.
        XCTAssertNil(delivered.document, "Wero delivery must carry no document")
        XCTAssertEqual(delivered.images.count, 0, "Wero delivery must carry no images")
        XCTAssertEqual(delivered.lineItems?.count, 0, "Wero delivery must carry no line items")
        XCTAssertEqual(networkDelegate.invalidQRMessageCallCount, 0,
                       "Direct-delivery Wero must not trigger the camera fallback")
        XCTAssertEqual(networkDelegate.noResultsCallCount, 0,
                       "Direct-delivery Wero must not trigger the no-results screen")
    }
}

// MARK: - ClientConfiguration Extension

extension ClientConfiguration {
    init(alreadyPaidHintEnabled: Bool = false,
         paymentDueHintEnabled: Bool = false,
         creditNoteHintEnabled: Bool = false,
         paymentScheduleHintEnabled: Bool = false,
         weroQRCodeScanningEnabled: Bool = false) {
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
                  paymentDueHintEnabled: paymentDueHintEnabled,
                  creditNoteHintEnabled: creditNoteHintEnabled,
                  paymentScheduleHintEnabled: paymentScheduleHintEnabled,
                  unsupportedQRCodeWarningEnabled: false,
                  ingredientBrandScreens: [],
                  weroQRCodeScanningEnabled: weroQRCodeScanningEnabled)
    }
}

// MARK: - Wero delivery fixture loader

private struct WeroDeliveryExtractionFixture: Decodable {
    let entity: String
    let value: String
}

/**
 Loads a named variant from `Resources/wero_delivery_fixtures.json` into an
 `ExtractionResult`. Mirrors the CaptureSDK side so test data lives in JSON
 rather than inline literals.
 */
private func loadWeroDeliveryFixture(_ variant: String) throws -> ExtractionResult {
    let data = try XCTUnwrap(FileLoader.loadFile(withName: "wero_delivery_fixtures", ofType: "json"),
                             "wero_delivery_fixtures.json missing from Bank SDK test bundle")
    let bundle = try JSONDecoder().decode([String: [String: WeroDeliveryExtractionFixture]].self, from: data)
    let raw = try XCTUnwrap(bundle[variant], "variant \(variant) not found in fixture")
    let extractions = raw.map { key, value in
        Extraction(box: nil, candidates: nil,
                   entity: value.entity, value: value.value, name: key)
    }
    return ExtractionResult(extractions: extractions, candidates: [:])
}
