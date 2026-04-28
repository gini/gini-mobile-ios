//
//  NetworkingScreenApiCoordinatorTests+CX.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import XCTest

// MARK: - CX Payment Tests

extension NetworkingScreenApiCoordinatorTests {

    // MARK: shouldShowReturnAssistant

    func testShouldNotShowReturnAssistantWhenCXEvenIfLineItemsPresent() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(lineItems: createMockLineItems())

        XCTAssertFalse(coordinator.shouldShowReturnAssistant(for: result),
                       "Return Assistant must be suppressed for CX regardless of lineItems presence")
    }

    func testShouldNotShowReturnAssistantWhenCXWithCrossBorderPaymentData() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(crossBorderPayment: createMockCrossBorderPayment())

        XCTAssertFalse(coordinator.shouldShowReturnAssistant(for: result),
                       "Return Assistant must be suppressed for CX even when crossBorderPayment data is present")
    }

    func testShouldShowReturnAssistantForSepaWhenLineItemsPresent() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        let result = createExtractionResult(lineItems: createMockLineItems())

        XCTAssertTrue(coordinator.shouldShowReturnAssistant(for: result),
                      "Return Assistant must remain available for SEPA when lineItems are present")
    }

    // MARK: shouldShowSkonto

    func testShouldNotShowSkontoWhenCXEvenIfSkontoDiscountsPresent() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.skontoEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(skontoDiscounts: createMockSkontoDiscounts())

        XCTAssertFalse(coordinator.shouldShowSkonto(for: result),
                       "Skonto must be suppressed for CX regardless of skontoDiscounts presence")
    }

    func testShouldNotShowSkontoWhenCXWithCrossBorderPaymentData() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.skontoEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(crossBorderPayment: createMockCrossBorderPayment())

        XCTAssertFalse(coordinator.shouldShowSkonto(for: result),
                       "Skonto must be suppressed for CX even when crossBorderPayment data is present")
    }

    func testShouldShowSkontoForSepaWhenSkontoDiscountsPresent() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.skontoEnabled = true
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        let result = createExtractionResult(skontoDiscounts: createMockSkontoDiscounts())

        XCTAssertTrue(coordinator.shouldShowSkonto(for: result),
                      "Skonto must remain available for SEPA when skontoDiscounts are present")
    }

    // MARK: determineIfPaymentDueHintEnabled

    func testPaymentDueHintDisabledForCX() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.paymentDueHintEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true)
        let result = createExtractionResult(paymentDueDate: "2025-12-31")

        XCTAssertFalse(coordinator.determineIfPaymentDueHintEnabled(for: result),
                       "Payment due hint must be suppressed for CX")
    }

    func testPaymentDueHintDisabledForCXWithCrossBorderPaymentData() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.paymentDueHintEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true)
        let result = createExtractionResult(crossBorderPayment: createMockCrossBorderPayment())

        XCTAssertFalse(coordinator.determineIfPaymentDueHintEnabled(for: result),
                       "Payment due hint must be suppressed for CX even when crossBorderPayment data is present")
    }

    func testPaymentDueHintEnabledForSepaWhenConditionsMet() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.paymentDueHintEnabled = true
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true)
        let result = createExtractionResult(paymentDueDate: "2025-12-31")

        XCTAssertTrue(coordinator.determineIfPaymentDueHintEnabled(for: result),
                      "Payment due hint must remain active for SEPA when globally enabled")
    }

    // MARK: determineIfAlreadyPaidHintEnabled

    func testAlreadyPaidHintDisabledForCX() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.alreadyPaidHintEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: true,
                                                                              paymentDueHintEnabled: false)
        let result = createExtractionResult()

        XCTAssertFalse(coordinator.determineIfAlreadyPaidHintEnabled(for: result),
                       "Already-paid hint must be suppressed for CX")
    }

    func testAlreadyPaidHintDisabledForCXWithCrossBorderPaymentData() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.alreadyPaidHintEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: true,
                                                                              paymentDueHintEnabled: false)
        let result = createExtractionResult(crossBorderPayment: createMockCrossBorderPayment())

        XCTAssertFalse(coordinator.determineIfAlreadyPaidHintEnabled(for: result),
                       "Already-paid hint must be suppressed for CX even when crossBorderPayment data is present")
    }

    func testAlreadyPaidHintEnabledForSepaWhenConditionsMet() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.alreadyPaidHintEnabled = true
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: true,
                                                                              paymentDueHintEnabled: false)
        let result = createExtractionResult()

        XCTAssertTrue(coordinator.determineIfAlreadyPaidHintEnabled(for: result),
                      "Already-paid hint must remain active for SEPA when globally enabled")
    }

    // MARK: autoDetectExtractions — non-CX behaviour

    func testShouldShowReturnAssistantForAutoDetectWhenLineItemsPresent() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        coordinator.giniBankConfiguration.productTag = .autoDetectExtractions
        let result = createExtractionResult(lineItems: createMockLineItems())

        XCTAssertTrue(coordinator.shouldShowReturnAssistant(for: result),
                      "Return Assistant must remain available for autoDetectExtractions when lineItems are present")
    }

    func testShouldShowSkontoForAutoDetectWhenDiscountsPresent() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.skontoEnabled = true
        coordinator.giniBankConfiguration.productTag = .autoDetectExtractions
        let result = createExtractionResult(skontoDiscounts: createMockSkontoDiscounts())

        XCTAssertTrue(coordinator.shouldShowSkonto(for: result),
                      "Skonto must remain available for autoDetectExtractions when skontoDiscounts are present")
    }

    func testPaymentDueHintEnabledForAutoDetectWhenConditionsMet() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.paymentDueHintEnabled = true
        coordinator.giniBankConfiguration.productTag = .autoDetectExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true)
        let result = createExtractionResult(paymentDueDate: "2025-12-31")

        XCTAssertTrue(coordinator.determineIfPaymentDueHintEnabled(for: result),
                      "Payment due hint must remain active for autoDetectExtractions when globally enabled")
    }

    // MARK: isCrossBorderPayment

    func testIsCXPaymentReturnsTrueForCXTag() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        XCTAssertTrue(coordinator.isCrossBorderPayment(),
                      "isCrossBorderPayment() must return true when productTag is .cxExtractions")
    }

    func testIsCXPaymentReturnsFalseForSepaTag() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        XCTAssertFalse(coordinator.isCrossBorderPayment(),
                       "isCrossBorderPayment() must return false when productTag is .sepaExtractions")
    }

    func testIsCXPaymentReturnsFalseForNilTag() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = nil
        XCTAssertFalse(coordinator.isCrossBorderPayment(),
                       "isCrossBorderPayment() must return false when productTag is nil")
    }

    func testIsCXPaymentReturnsFalseForAutoDetectTag() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .autoDetectExtractions
        XCTAssertFalse(coordinator.isCrossBorderPayment(),
                       "isCrossBorderPayment() must return false when productTag is .autoDetectExtractions")
    }

    // MARK: shouldShowNoResultsForCX

    func testShouldShowNoResultsForCXWhenCXTagAndCrossBorderPaymentIsNil() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(crossBorderPayment: nil)

        XCTAssertTrue(coordinator.shouldShowNoResultsForCrossBorder(for: result),
                      "Must show no-results when CX tag is set and crossBorderPayment is nil")
    }

    func testShouldShowNoResultsForCXWhenCXTagAndCrossBorderPaymentIsEmpty() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(crossBorderPayment: [])

        XCTAssertTrue(coordinator.shouldShowNoResultsForCrossBorder(for: result),
                      "Must show no-results when CX tag is set and crossBorderPayment is an empty array")
    }

    func testShouldNotShowNoResultsForCXWhenCXTagAndCrossBorderPaymentIsPresent() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(crossBorderPayment: createMockCrossBorderPayment())

        XCTAssertFalse(coordinator.shouldShowNoResultsForCrossBorder(for: result),
                       "Must NOT show no-results when CX tag is set and crossBorderPayment has data")
    }

    func testShouldNotShowNoResultsForCXWhenSepaTagEvenIfCrossBorderPaymentIsNil() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        let result = createExtractionResult(crossBorderPayment: nil)

        XCTAssertFalse(coordinator.shouldShowNoResultsForCrossBorder(for: result),
                       "Must NOT show CX no-results when productTag is SEPA")
    }

    func testShouldNotShowNoResultsForCXWhenTagIsNil() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = nil
        let result = createExtractionResult(crossBorderPayment: nil)

        XCTAssertFalse(coordinator.shouldShowNoResultsForCrossBorder(for: result),
                       "Must NOT show CX no-results when productTag is nil")
    }

    // MARK: Partial CX response

    func testPartialCXResponseDoesNotTriggerNoResultsScreen() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(crossBorderPayment: createPartialCrossBorderPayment())

        XCTAssertFalse(coordinator.shouldShowNoResultsForCrossBorder(for: result),
                       "A partial crossBorderPayment (some fields absent) is a valid result — no-results screen must not be shown")
    }

    func testPartialCXResponseContainsOnlyReturnedFields() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let partial = createPartialCrossBorderPayment()
        let result = createExtractionResult(crossBorderPayment: partial)

        let group = try XCTUnwrap(result.crossBorderPayment?.first,
                                  "crossBorderPayment must contain at least one group")
        XCTAssertEqual(group.count, 1,
                       "Partial response group must contain exactly the one field the backend returned")
        XCTAssertEqual(group.first?.name, "iban",
                       "The only returned field must be 'iban'")
    }

    func testPartialCXResponseSuppressesReturnAssistantAndSkonto() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        coordinator.giniBankConfiguration.returnAssistantEnabled = true
        coordinator.giniBankConfiguration.skontoEnabled = true
        coordinator.giniBankConfiguration.productTag = .cxExtractions
        let result = createExtractionResult(lineItems: createMockLineItems(),
                                            skontoDiscounts: createMockSkontoDiscounts(),
                                            crossBorderPayment: createPartialCrossBorderPayment())

        XCTAssertFalse(coordinator.shouldShowReturnAssistant(for: result),
                       "Return Assistant must be suppressed even for a partial CX response")
        XCTAssertFalse(coordinator.shouldShowSkonto(for: result),
                       "Skonto must be suppressed even for a partial CX response")
    }
}
