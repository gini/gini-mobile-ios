//
//  NetworkingScreenApiCoordinatorTests+DueDateHint.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import XCTest

// MARK: - Due Date Hint gate

extension NetworkingScreenApiCoordinatorTests {

    // MARK: shouldPresentDueDateHint

    func testShouldPresentDueDateHintWhenDueDateIsBeyondThreshold() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))

        XCTAssertTrue(coordinator.shouldPresentDueDateHint(for: result),
                      "Due Date Hint must be presented when the due date is comfortably beyond the threshold")
    }

    func testShouldNotPresentDueDateHintWhenDueDateIsToday() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 0))

        XCTAssertFalse(coordinator.shouldPresentDueDateHint(for: result),
                       "isDueSoon(within: 5) with daysUntilDue=0 → 1 >= 5 → false; today must not trigger a hint")
    }

    func testShouldNotPresentDueDateHintWhenDueDateIsInThePast() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: -3))

        XCTAssertFalse(coordinator.shouldPresentDueDateHint(for: result),
                       "Past due dates must never trigger a hint")
    }

    func testShouldPresentDueDateHintAtLegacyBoundary() throws {
        // isDueSoon(within: 5) fires when daysUntilDue + 1 >= 5, i.e. daysUntilDue ≥ 4.
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 4))

        XCTAssertTrue(coordinator.shouldPresentDueDateHint(for: result),
                      "isDueSoon(within: 5) must fire at daysUntilDue = 4 (5 inclusive days)")
    }

    func testShouldNotPresentDueDateHintBelowLegacyBoundary() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 3))

        XCTAssertFalse(coordinator.shouldPresentDueDateHint(for: result),
                       "isDueSoon(within: 5) must not fire at daysUntilDue = 3 (4 inclusive days)")
    }

    func testShouldPresentDueDateHintRespectsCustomThreshold() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 3

        // isDueSoon(within: 3) with daysUntilDue = 2 → 3 >= 3 → true.
        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 2))

        XCTAssertTrue(coordinator.shouldPresentDueDateHint(for: result),
                      "Custom threshold (3) must fire at daysUntilDue = 2")
    }

    func testShouldNotPresentDueDateHintWhenPaymentDueHintDisabled() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintEnabled = false

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))

        XCTAssertFalse(coordinator.shouldPresentDueDateHint(for: result),
                       "Due Date Hint must be suppressed when paymentDueHintEnabled is off")
    }

    func testShouldNotPresentDueDateHintWhenReturnAssistantWins() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.returnAssistantEnabled = true

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10),
                                            lineItems: createMockLineItems())

        XCTAssertFalse(coordinator.shouldPresentDueDateHint(for: result),
                       "Return Assistant must take priority over the Due Date Hint")
    }

    func testShouldNotPresentDueDateHintWhenSkontoWins() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.skontoEnabled = true

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10),
                                            skontoDiscounts: createMockSkontoDiscounts())

        XCTAssertFalse(coordinator.shouldPresentDueDateHint(for: result),
                       "Skonto must take priority over the Due Date Hint")
    }

    func testShouldNotPresentDueDateHintWhenPaymentDueDateIsMissing() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForDueDateHint(coordinator)

        let result = createExtractionResult(paymentDueDate: nil)

        XCTAssertFalse(coordinator.shouldPresentDueDateHint(for: result),
                       "Due Date Hint requires a paymentDueDate extraction")
    }

    // MARK: - Helpers

    private func configureForDueDateHint(_ coordinator: GiniBankNetworkingScreenApiCoordinator) {
        coordinator.giniBankConfiguration.paymentDueHintEnabled = true
        coordinator.giniBankConfiguration.returnAssistantEnabled = false
        coordinator.giniBankConfiguration.skontoEnabled = false
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true)
    }

    private func dateString(daysFromNow days: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

