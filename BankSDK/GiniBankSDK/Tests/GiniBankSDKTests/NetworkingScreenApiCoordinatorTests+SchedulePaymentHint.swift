//
//  NetworkingScreenApiCoordinatorTests+SchedulePaymentHint.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import UIKit
import XCTest

// MARK: - Schedule Payment Hint gate

extension NetworkingScreenApiCoordinatorTests {

    // MARK: shouldPresentSchedulePaymentHint

    func testShouldPresentSchedulePaymentHintWhenBothFlagsAndEligibleDueDate() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))

        XCTAssertTrue(coordinator.shouldPresentSchedulePaymentHint(for: result),
                      "Schedule Payment Hint must fire when both flags are on and the due date is beyond the threshold")
    }

    func testShouldNotPresentSchedulePaymentHintWhenGlobalFlagOff() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentScheduleHintEnabled = false

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Schedule Payment Hint must be suppressed when GiniBankConfiguration.paymentScheduleHintEnabled is off")
    }

    func testShouldNotPresentSchedulePaymentHintWhenClientFlagOff() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true,
                                                                              paymentScheduleHintEnabled: false)

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Schedule Payment Hint must be suppressed when ClientConfiguration.paymentScheduleHintEnabled is off")
    }

    func testShouldNotPresentSchedulePaymentHintWhenDueDateIsToday() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 0))

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Schedule Payment Hint must not fire when the due date is today")
    }

    func testShouldNotPresentSchedulePaymentHintWhenDueDateIsInThePast() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: -3))

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Schedule Payment Hint must not fire when the due date is in the past")
    }

    func testShouldNotPresentSchedulePaymentHintBelowThreshold() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        /// isDueSoon(within: 5) with daysUntilDue = 3 → 4 >= 5 → false.
        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 3))

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Schedule Payment Hint must not fire under the threshold")
    }

    func testShouldNotPresentSchedulePaymentHintWhenCrossBorder() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.productTag = .cxExtractions

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10),
                                            crossBorderPayment: createMockCrossBorderPayment())

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Schedule Payment Hint must be suppressed for Cross-Border Payment flows")
    }

    func testShouldNotPresentSchedulePaymentHintWhenReturnAssistantWins() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.returnAssistantEnabled = true

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10),
                                            lineItems: createMockLineItems())

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Return Assistant must take priority over the Schedule Payment Hint")
    }

    func testShouldNotPresentSchedulePaymentHintWhenSkontoWins() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.skontoEnabled = true

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10),
                                            skontoDiscounts: createMockSkontoDiscounts())

        XCTAssertFalse(coordinator.shouldPresentSchedulePaymentHint(for: result),
                       "Skonto must take priority over the Schedule Payment Hint")
    }

    // MARK: handleToBePaidCase — priority coverage

    @MainActor
    func testHandleToBePaidCasePresentsScheduleStateWhenBothFlagsOn() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountSchedulingWindow(for: coordinator)
        defer { tearDownSchedulingWindow(window) }
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))
        var continuationCalled = false
        coordinator.handleToBePaidCase(result) { continuationCalled = true }

        let sheet = try waitForPresentedSchedulingSheet(on: coordinator)
        XCTAssertFalse(continuationCalled,
                       "When the schedule sheet is up, the continuation must wait for the user's CTA")

        let scheduleButtonTitle = sheet.buttonTitle(at: 0)
        XCTAssertEqual(scheduleButtonTitle,
                       PaymentHintBottomSheetViewController.Strings.scheduleButton,
                       "The presented sheet must be in .schedulePayment state (primary = Schedule Payment)")
    }

    @MainActor
    func testHandleToBePaidCasePresentsDueDateStateWhenScheduleFlagOff() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountSchedulingWindow(for: coordinator)
        defer { tearDownSchedulingWindow(window) }
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentScheduleHintEnabled = false
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))
        var continuationCalled = false
        coordinator.handleToBePaidCase(result) { continuationCalled = true }

        let sheet = try waitForPresentedSchedulingSheet(on: coordinator)
        XCTAssertFalse(continuationCalled,
                       "When the due-date sheet is up, the continuation must wait for the user's CTA")

        let primaryButtonTitle = sheet.buttonTitle(at: 0)
        XCTAssertEqual(primaryButtonTitle,
                       PaymentHintBottomSheetViewController.Strings.dueDateProceedButton,
                       "With paymentScheduleHintEnabled off, the sheet must be in .dueDate state (primary = Proceed Anyway)")
    }

    @MainActor
    func testHandleToBePaidCaseInvokesContinuationSynchronouslyWhenBothFlagsOff() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountSchedulingWindow(for: coordinator)
        defer { tearDownSchedulingWindow(window) }
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentScheduleHintEnabled = false
        coordinator.giniBankConfiguration.paymentDueHintEnabled = false

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))
        var continuationCalled = false
        coordinator.handleToBePaidCase(result) { continuationCalled = true }

        XCTAssertTrue(continuationCalled,
                      "With both flags off, the continuation must fire synchronously and no sheet is presented")
        XCTAssertNil(coordinator.screenAPINavigationController.presentedViewController,
                     "With both flags off, no sheet must be presented")
    }

    // MARK: presentPaymentHintBottomSheet(.schedulePayment) — flow-level coverage

    @MainActor
    func testPresentScheduleSheetIsModalAndHidesDragIndicator() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountSchedulingWindow(for: coordinator)
        defer { tearDownSchedulingWindow(window) }

        coordinator.presentPaymentHintBottomSheet(
            state: .schedulePayment(formattedDueDate: Date().toDisplayString(),
                                    onSchedule: {},
                                    onProceed: {})
        )

        let sheet = try waitForPresentedSchedulingSheet(on: coordinator)
        XCTAssertTrue(sheet.isModalInPresentation,
                      "Schedule sheet must not be dismissible by tap-outside or swipe")
        XCTAssertFalse(sheet.shouldShowDragIndicator,
                       "Schedule sheet must hide the drag indicator")
    }

    @MainActor
    func testPresentScheduleSheetPrimaryInvokesScheduleDelegate() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountSchedulingWindow(for: coordinator)
        defer { tearDownSchedulingWindow(window) }
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5
        XCTAssertTrue(resultsDelegate.scheduleRequestedResults.isEmpty,
                      "Precondition: no schedule request has been delivered yet")

        let extractionResult = createExtractionResult(paymentState: "to_be_paid",
                                                      paymentDueDate: dateString(daysFromNow: 10))
        coordinator.handleToBePaidCase(extractionResult) {
            XCTFail("Schedule CTA must not invoke the pay-now continuation")
        }

        let sheet = try waitForPresentedSchedulingSheet(on: coordinator)
        sheet.didPressPrimary()

        XCTAssertEqual(resultsDelegate.scheduleRequestedResults.count, 1,
                       "Schedule CTA must invoke giniCaptureDidRequestSchedulePayment exactly once")
        let delivered = try XCTUnwrap(resultsDelegate.scheduleRequestedResults.first)
        XCTAssertNotNil(delivered.extractions["paymentDueDate"],
                        "Delivered AnalysisResult must carry the extractions dictionary keyed by extraction name")
        XCTAssertFalse(coordinator.screenAPINavigationController.view.accessibilityElementsHidden,
                       "Presenter must be re-exposed to VoiceOver before the delegate hand-off")
    }

    @MainActor
    func testPresentScheduleSheetSecondaryInvokesProceedContinuation() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountSchedulingWindow(for: coordinator)
        defer { tearDownSchedulingWindow(window) }
        configureForSchedulePaymentHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5
        XCTAssertTrue(resultsDelegate.scheduleRequestedResults.isEmpty,
                      "Precondition: no schedule request has been delivered yet")

        var proceedCalled = false
        let extractionResult = createExtractionResult(paymentState: "to_be_paid",
                                                      paymentDueDate: dateString(daysFromNow: 10))
        coordinator.handleToBePaidCase(extractionResult) { proceedCalled = true }

        let sheet = try waitForPresentedSchedulingSheet(on: coordinator)
        sheet.didPressSecondary()

        XCTAssertTrue(proceedCalled,
                      "Proceed Anyway must invoke the pay-now continuation synchronously")
        XCTAssertTrue(resultsDelegate.scheduleRequestedResults.isEmpty,
                      "Proceed Anyway must NOT invoke the schedule delegate")
    }

    // MARK: - Helpers

    @MainActor
    private func mountSchedulingWindow(for coordinator: GiniBankNetworkingScreenApiCoordinator) -> UIWindow {
        /// Disable UIKit animations so `present(animated: true)` / `dismiss(animated: true)`
        /// completions fire near-synchronously on CI simulators.
        UIView.setAnimationsEnabled(false)
        let nav = coordinator.screenAPINavigationController
        if nav.viewControllers.isEmpty {
            nav.viewControllers = [UIViewController()]
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        return window
    }

    @MainActor
    private func tearDownSchedulingWindow(_ window: UIWindow) {
        window.isHidden = true
        UIView.setAnimationsEnabled(true)
    }

    @MainActor
    private func waitForPresentedSchedulingSheet(on coordinator: GiniBankNetworkingScreenApiCoordinator)
        throws -> PaymentHintBottomSheetViewController {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                coordinator.screenAPINavigationController.presentedViewController is PaymentHintBottomSheetViewController
            },
            object: nil
        )
        wait(for: [expectation], timeout: 5.0)
        return try XCTUnwrap(
            coordinator.screenAPINavigationController.presentedViewController as? PaymentHintBottomSheetViewController,
            "Sheet must be presented over the nav controller"
        )
    }

    private func configureForSchedulePaymentHint(_ coordinator: GiniBankNetworkingScreenApiCoordinator) {
        coordinator.giniBankConfiguration.paymentScheduleHintEnabled = true
        coordinator.giniBankConfiguration.paymentDueHintEnabled = true
        coordinator.giniBankConfiguration.returnAssistantEnabled = false
        coordinator.giniBankConfiguration.skontoEnabled = false
        coordinator.giniBankConfiguration.productTag = .sepaExtractions
        GiniBankUserDefaultsStorage.clientConfiguration = ClientConfiguration(alreadyPaidHintEnabled: false,
                                                                              paymentDueHintEnabled: true,
                                                                              paymentScheduleHintEnabled: true)
    }

    /// Local peer of the private `dateString(daysFromNow:)` in `+DueDateHint.swift` — kept
    /// per-file so each extension is self-contained.
    fileprivate func dateString(daysFromNow days: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

// MARK: - Sheet button introspection

private extension PaymentHintBottomSheetViewController {
    @MainActor
    func buttonTitle(at index: Int) -> String? {
        _ = view
        let buttons = allButtons(in: view)
        guard buttons.indices.contains(index) else { return nil }
        return buttons[index].titleLabel?.text ?? buttons[index].title(for: .normal)
    }

    @MainActor
    private func allButtons(in view: UIView) -> [UIButton] {
        var result = view.subviews.compactMap { $0 as? UIButton }
        result += view.subviews.flatMap { allButtons(in: $0) }
        return result
    }
}
