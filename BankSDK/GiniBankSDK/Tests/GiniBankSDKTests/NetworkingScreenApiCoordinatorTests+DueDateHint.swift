//
//  NetworkingScreenApiCoordinatorTests+DueDateHint.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import UIKit
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
        /// isDueSoon(within: 5) fires when daysUntilDue + 1 >= 5, i.e. daysUntilDue ≥ 4.
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

        /// isDueSoon(within: 3) with daysUntilDue = 2 → 3 >= 3 → true.
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

    // MARK: presentDueDateHintBottomSheet — flow-level coverage

    @MainActor
    func testPresentDueDateHintBottomSheetShowsModalNonDismissibleSheet() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountNavigationController(for: coordinator)
        defer { tearDownWindow(window) }

        coordinator.presentDueDateHintBottomSheet(dueDate: Date()) { }

        let sheetVisible = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                coordinator.screenAPINavigationController.presentedViewController is DueDateHintBottomSheetViewController
            },
            object: nil
        )
        wait(for: [sheetVisible], timeout: 5.0)

        let sheet = try XCTUnwrap(
            coordinator.screenAPINavigationController.presentedViewController as? DueDateHintBottomSheetViewController,
            "Sheet must be presented over the nav controller"
        )
        XCTAssertTrue(sheet.isModalInPresentation,
                      "Sheet must not be dismissible by tap-outside or swipe — CTA-driven only")
        XCTAssertFalse(sheet.shouldShowDragIndicator,
                       "Sheet must hide the drag indicator — CTA-driven only")
    }

    @MainActor
    func testPresentDueDateHintBottomSheetProceedInvokesContinuation() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountNavigationController(for: coordinator)
        defer { tearDownWindow(window) }

        var proceedCalled = false
        coordinator.presentDueDateHintBottomSheet(dueDate: Date()) { proceedCalled = true }

        let sheet = try waitForPresentedDueDateSheet(on: coordinator)
        sheet.didPressPrimary()

        XCTAssertTrue(proceedCalled,
                      "Primary CTA must invoke the continuation synchronously")
        XCTAssertFalse(coordinator.screenAPINavigationController.view.accessibilityElementsHidden,
                       "Presenter must be re-exposed to VoiceOver before dismiss animates out")
    }

    @MainActor
    func testPresentDueDateHintBottomSheetCancelNotifiesResultsDelegate() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountNavigationController(for: coordinator)
        defer { tearDownWindow(window) }
        XCTAssertFalse(resultsDelegate.closeCalled,
                       "Precondition: resultsDelegate must not have been notified yet")

        coordinator.presentDueDateHintBottomSheet(dueDate: Date()) {
            XCTFail("Cancel path must not invoke the continuation")
        }

        let sheet = try waitForPresentedDueDateSheet(on: coordinator)
        sheet.didPressSecondary()

        XCTAssertTrue(resultsDelegate.closeCalled,
                      "Secondary CTA must call giniCaptureDidCancelAnalysis synchronously")
        XCTAssertFalse(coordinator.screenAPINavigationController.view.accessibilityElementsHidden,
                       "Presenter must be re-exposed to VoiceOver before dismiss animates out")
    }

    // MARK: handleToBePaidCase — branch coverage

    @MainActor
    func testHandleToBePaidCaseInvokesContinuationImmediatelyWhenGateFails() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountNavigationController(for: coordinator)
        defer { tearDownWindow(window) }
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintEnabled = false

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))
        var continuationCalled = false
        coordinator.handleToBePaidCase(result) { continuationCalled = true }

        XCTAssertTrue(continuationCalled,
                      "When the gate fails, the continuation must fire synchronously")
        XCTAssertNil(coordinator.screenAPINavigationController.presentedViewController,
                     "When the gate fails, no sheet must be presented")
    }

    @MainActor
    func testHandleToBePaidCasePresentsSheetWhenGatesPass() throws {
        let (coordinator, _) = try makeCoordinatorAndService()
        let window = mountNavigationController(for: coordinator)
        defer { tearDownWindow(window) }
        configureForDueDateHint(coordinator)
        coordinator.giniBankConfiguration.paymentDueHintThresholdDays = 5

        let result = createExtractionResult(paymentDueDate: dateString(daysFromNow: 10))
        var continuationCalled = false
        coordinator.handleToBePaidCase(result) { continuationCalled = true }

        _ = try waitForPresentedDueDateSheet(on: coordinator)
        XCTAssertFalse(continuationCalled,
                       "When the sheet is presented, the continuation must wait for the user's CTA")
    }

    // MARK: - Helpers

    @MainActor
    private func mountNavigationController(for coordinator: GiniBankNetworkingScreenApiCoordinator) -> UIWindow {
        /// Disable UIKit animations so `present(animated: true)` / `dismiss(animated: true)`
        /// completions fire near-synchronously. Without this, CI simulators can take
        /// several seconds to drive the animation frames and the wait predicates time out.
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
    private func tearDownWindow(_ window: UIWindow) {
        window.isHidden = true
        UIView.setAnimationsEnabled(true)
    }

    @MainActor
    private func waitForPresentedDueDateSheet(on coordinator: GiniBankNetworkingScreenApiCoordinator)
        throws -> DueDateHintBottomSheetViewController {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                coordinator.screenAPINavigationController.presentedViewController is DueDateHintBottomSheetViewController
            },
            object: nil
        )
        wait(for: [expectation], timeout: 5.0)
        return try XCTUnwrap(
            coordinator.screenAPINavigationController.presentedViewController as? DueDateHintBottomSheetViewController,
            "Sheet must be presented over the nav controller"
        )
    }

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

