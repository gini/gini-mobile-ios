//
//  PaymentHintFlowUITests.swift
//  GiniBankSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 BrowserStack UI-automation for the payment-hint bottom sheet — see
 `specs/PP-3302-feature.md` for the requirement→test mapping.

 Fixtures (shared 1:1 with Android PP-3301, uploaded by `Scripts/bs_run_payment_hint.sh`):
 `invoice_future_due.jpeg` (offset 0) → `paymentDueDate = 2028-09-01`;
 `invoice_no_due_date.jpeg` (offset 1) → no `paymentDueDate`. Regenerate
 from `gini-mobile-android@release/bank-sdk-4.5` before mid-2028 and
 update `FIXTURE_DUE_DATE`.

 Show / no-show cases are driven by varying `-paymentDueHintThresholdDaysOverride`,
 not by refreshing the invoice.
 */
final class PaymentHintFlowUITests: GiniBankSDKExampleUITests {

    // MARK: - Fixture

    /// Encoded on `invoice_future_due.jpeg`. Validated against the real
    /// Gini API with the `gini-mobile-test` client on 2026-08-17.
    ///
    /// Parsed identically to how the SDK ingests the API-returned `paymentDueDate`
    /// (`Date.date(from:)` — `yyyy-MM-dd` in the device's default timezone), so
    /// `remainingDays()` here and `Date.isDueSoon(within:)` inside the SDK always agree
    /// regardless of the device's timezone. Pinning this to Europe/Berlin drifted by 1 day
    /// on UTC-configured BS devices and broke the boundary math in `testSheetDoesNotAppearBelowThreshold`.
    private static let FIXTURE_DUE_DATE: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: "2028-09-01")!
    }()

    /// `FIXTURE_DUE_DATE` as `dd.MM.yyyy` — locale-independent substring for title assertion.
    /// Formatter uses the device's default timezone to match the SDK's `Date.toDisplayString`.
    private static let FIXTURE_DUE_DATE_FORMATTED: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: FIXTURE_DUE_DATE)
    }()

    override var additionalLaunchArguments: [String] { ["-DisableReturnAssistant"] }

    // MARK: - Helpers

    private var paymentHintScreen: PaymentHintScreen!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentHintScreen = PaymentHintScreen(app: app)
    }

    /// Days between today and `FIXTURE_DUE_DATE`, computed like `Date.isDueSoon(within:)`.
    private func remainingDays() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: Self.FIXTURE_DUE_DATE)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }

    /// True within 30 min of midnight. Used to skip boundary-threshold tests
    /// (mirrors Android PP-3301) — a date rollover between setup and the
    /// coordinator's computation would flip the boundary the wrong way.
    private var isNearMidnight: Bool {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesSinceMidnight = hour * 60 + minute
        return minutesSinceMidnight < 30 || minutesSinceMidnight >= 23 * 60 + 30
    }

    /// Relaunches with the given threshold override. Tests rely on the real Gini API
    /// extraction of `invoice_future_due.jpeg` (`paymentState = ToBePaid`,
    /// `paymentDueDate = 2028-09-01`) — no injection seam is needed.
    private func relaunchApp(thresholdOverride: Int) {
        extraLaunchArguments = ["-paymentDueHintThresholdDaysOverride", "\(thresholdOverride)"]
        relaunch()
    }

    /// Toggles both payment-hint switches via the Settings screen. Assumes main screen.
    private func setPaymentHintFlags(dueDate: Bool, schedule: Bool) {
        mainScreen.configurationButton.tap()
        settingScreen.setPaymentHintFlags(dueDate: dueDate, schedule: schedule)
        settingScreen.closeButton.tap()
    }

    /// Runs the Photopayment flow up to (but not through) the payment-hint sheet.
    /// `offset` 0 → `invoice_future_due`, 1 → `invoice_no_due_date` (see file header).
    private func runFlowToAnalysis(photoOffset: Int) {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery(offset: photoOffset)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear on the review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
    }

    private var extractionDoneButton: XCUIElement { app.navigationBars.buttons["Done"] }

    /// Confirms the results screen was reached and the SDK closes back to the host's main screen.
    /// Between analysis completion and the results screen the SDK may present a Transaction Docs
    /// alert (host + client both opt in, first run on that device). On BrowserStack the alert
    /// always shows and would block the results screen; locally with a cold install it may not.
    /// Dismiss it with the "only-for-this-transaction" choice if present, then tap the
    /// results-screen Done button (`mainScreen.sendFeedbackButton`) to close the SDK, and assert
    /// we're back on main.
    ///
    /// `waitForResults` bounds how long we allow between the caller's last step (tapping Process /
    /// proceed) and the alert appearing — effectively covers the real Gini API extraction time.
    private func assertExtractionReachesMainScreen(waitForResults: TimeInterval) {
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: waitForResults) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        // Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5),
                      "Send feedback (Done) button should appear on the results screen")
        mainScreen.sendFeedbackButton.tap()
        // Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Main screen (Photopayment button) should be reached after closing the SDK")
    }

    // MARK: - R1: Due Date Hint sheet appears

    func testDueDateSheetAppearsWithDefaultThreshold() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet(),
                      "Due Date Hint container should appear within 60 s")
        XCTAssertTrue(paymentHintScreen.dueDateTitle.label.contains(Self.FIXTURE_DUE_DATE_FORMATTED),
                      "Title label should contain the formatted due date \(Self.FIXTURE_DUE_DATE_FORMATTED)")
    }

    // MARK: - R2: Schedule Payment sheet appears (priority)

    func testScheduleSheetAppearsWhenBothFlagsOn() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet(),
                      "Schedule container should appear when both flags are on (schedule priority)")
        XCTAssertFalse(paymentHintScreen.dueDateContainer.waitForExistence(timeout: 3),
                       "Due Date container should NOT appear when schedule is enabled")
    }

    func testScheduleSheetAppearsWhenOnlyScheduleFlagOn() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: false, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet(),
                      "Schedule container should appear when only schedule flag is on")
    }

    // MARK: - R3: Boundary — threshold == remainingDays

    func testSheetAppearsAtBoundaryThreshold() throws {
        try XCTSkipIf(isNearMidnight,
                      "Skipping boundary threshold test within 30 min of midnight to avoid date-rollover flake")

        let boundary = remainingDays()
        relaunchApp(thresholdOverride: boundary)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet(),
                      "Due Date Hint sheet should appear at boundary (threshold == remainingDays = \(boundary))")
    }

    // MARK: - R4: Below threshold — threshold > remainingDays

    func testSheetDoesNotAppearBelowThreshold() throws {
        try XCTSkipIf(isNearMidnight,
                      "Skipping below-threshold test within 30 min of midnight to avoid date-rollover flake")

        // `isDueSoon(within: N)` fires when `daysUntilDue + 1 >= N`, so the largest firing
        // threshold is `remainingDays + 1`. Use `remainingDays + 2` to sit strictly above it.
        relaunchApp(thresholdOverride: remainingDays() + 2)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertFalse(paymentHintScreen.dueDateContainer.waitForExistence(timeout: 30),
                       "Due Date container should NOT appear when threshold exceeds remainingDays")
        XCTAssertFalse(paymentHintScreen.scheduleContainer.exists,
                       "Schedule container should NOT appear when threshold exceeds remainingDays")
        assertExtractionReachesMainScreen(waitForResults: 60)
    }

    // MARK: - R5: Flags-off suppression

    func testFlagsOffProceedsDirectlyToExtraction() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: false, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertFalse(paymentHintScreen.dueDateContainer.waitForExistence(timeout: 30),
                       "Due Date container should NOT appear with both flags off")
        XCTAssertFalse(paymentHintScreen.scheduleContainer.exists,
                       "Schedule container should NOT appear with both flags off")
        assertExtractionReachesMainScreen(waitForResults: 60)
    }

    // MARK: - R6: No paymentDueDate extracted → no sheet

    func testNoSheetWhenPaymentDueDateExtractionEmpty() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 1)

        XCTAssertFalse(paymentHintScreen.dueDateContainer.waitForExistence(timeout: 30),
                       "Due Date container should NOT appear when extraction has no paymentDueDate")
        XCTAssertFalse(paymentHintScreen.scheduleContainer.exists,
                       "Schedule container should NOT appear when extraction has no paymentDueDate")
        assertExtractionReachesMainScreen(waitForResults: 60)
    }

    // MARK: - R7: Due Date "Proceed Anyway" → extraction screen

    func testDueDateProceedAnywayContinuesToExtraction() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        let dueDateContainer = app.otherElements["paymentHint.dueDate.container"]
        XCTAssertTrue(dueDateContainer.waitForExistence(timeout: 10),
                      "Due date container should appear")
        paymentHintScreen.dueDateProceedButton.tap()

        XCTAssertTrue(paymentHintScreen.dueDateContainer.waitForNonExistence(timeout: 3),
                      "Due Date container should dismiss within 3 s of tapping Proceed Anyway")
        assertExtractionReachesMainScreen(waitForResults: 15)
    }

    // MARK: - R8: Due Date "Cancel Transfer" → main screen, extraction NOT reached

    func testDueDateCancelTransferReturnsToMain() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet())
        paymentHintScreen.dueDateCancelButton.tap()

        XCTAssertTrue(paymentHintScreen.dueDateContainer.waitForNonExistence(timeout: 3),
                      "Due Date container should dismiss within 3 s of tapping Cancel Transfer")
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10),
                      "Main screen should be visible within 10 s after Cancel Transfer")
        XCTAssertFalse(extractionDoneButton.exists,
                       "Extraction screen should NOT be reached after Cancel Transfer")
    }

    // MARK: - R9: Schedule CTA → schedule-callback alert

    func testScheduleCTAFiresScheduleCallback() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet())
        paymentHintScreen.scheduleButton.tap()

        let alert = app.alerts["Schedule Payment requested"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5),
                      "Schedule Payment alert should appear within 5 s of tapping Schedule Payment")
        XCTAssertFalse(extractionDoneButton.exists,
                       "Extraction screen should NOT be visible after Schedule Payment")
    }

    // MARK: - R10: Schedule "Proceed Anyway" → extraction, no alert

    func testScheduleProceedAnywayContinuesToExtractionWithoutAlert() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        let scheduleContainer = app.otherElements["paymentHint.schedule.container"]
        XCTAssertTrue(scheduleContainer.waitForExistence(timeout: 10),
                      "Schedule container should appear")
        paymentHintScreen.scheduleProceedButton.tap()

        XCTAssertTrue(paymentHintScreen.scheduleContainer.waitForNonExistence(timeout: 3),
                      "Schedule container should dismiss within 3 s of tapping Proceed Anyway")
        XCTAssertFalse(app.alerts["Schedule Payment requested"].exists,
                       "Schedule Payment alert should NOT appear when tapping Proceed Anyway")
        assertExtractionReachesMainScreen(waitForResults: 15)
    }

    // MARK: - R11: Backdrop tap does NOT dismiss

    func testBackdropTapDoesNotDismissDueDate() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet())

        let backdropTap = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        backdropTap.tap()

        XCTAssertTrue(paymentHintScreen.dueDateContainer.exists,
                      "Due Date container should remain visible after a backdrop tap")
        /// Small wait to be sure a delayed dismissal doesn't sneak in.
        Thread.sleep(forTimeInterval: 3)
        XCTAssertTrue(paymentHintScreen.dueDateContainer.exists,
                      "Due Date container should still be visible 3 s after a backdrop tap")
    }

    func testBackdropTapDoesNotDismissSchedule() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet())

        let backdropTap = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        backdropTap.tap()

        XCTAssertTrue(paymentHintScreen.scheduleContainer.exists,
                      "Schedule container should remain visible after a backdrop tap")
        Thread.sleep(forTimeInterval: 3)
        XCTAssertTrue(paymentHintScreen.scheduleContainer.exists,
                      "Schedule container should still be visible 3 s after a backdrop tap")
    }

    // MARK: - R12: Capture-suggestions banner suppressed while sheet is up

    func testCaptureSuggestionsSuppressedWhileDueDateSheetVisible() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet())
        /// The capture-suggestions banner appears after 4 s on the Analysis
        /// screen; wait past that window before asserting non-presence.
        Thread.sleep(forTimeInterval: 5)

        XCTAssertTrue(paymentHintScreen.dueDateContainer.exists,
                      "Due Date container must still be up when this assertion runs")
        let suggestions = app.otherElements
            .matching(NSPredicate(format: "identifier CONTAINS[c] 'analysisHint'"))
            .firstMatch
        XCTAssertFalse(suggestions.isHittable,
                       "Capture-suggestions banner must not be hittable while the Due Date sheet is up")
    }

    func testCaptureSuggestionsSuppressedWhileScheduleSheetVisible() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet())
        Thread.sleep(forTimeInterval: 5)

        XCTAssertTrue(paymentHintScreen.scheduleContainer.exists,
                      "Schedule container must still be up when this assertion runs")
        let suggestions = app.otherElements
            .matching(NSPredicate(format: "identifier CONTAINS[c] 'analysisHint'"))
            .firstMatch
        XCTAssertFalse(suggestions.isHittable,
                       "Capture-suggestions banner must not be hittable while the Schedule sheet is up")
    }

    // MARK: - R13: Dynamic Type AXXXL does not truncate the sheet

    func testAXXXLDoesNotTruncateDueDateSheet() throws {
        extraLaunchArguments = [
            "-paymentDueHintThresholdDaysOverride", "5",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        relaunch()

        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet())
        assertNoTruncation(container: paymentHintScreen.dueDateContainer,
                           title: paymentHintScreen.dueDateTitle,
                           primary: paymentHintScreen.dueDateProceedButton,
                           secondary: paymentHintScreen.dueDateCancelButton)
    }

    func testAXXXLDoesNotTruncateScheduleSheet() throws {
        extraLaunchArguments = [
            "-paymentDueHintThresholdDaysOverride", "5",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        relaunch()

        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(photoOffset: 0)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet())
        assertNoTruncation(container: paymentHintScreen.scheduleContainer,
                           title: paymentHintScreen.scheduleTitle,
                           primary: paymentHintScreen.scheduleButton,
                           secondary: paymentHintScreen.scheduleProceedButton)
    }

    private func assertNoTruncation(container: XCUIElement,
                                    title: XCUIElement,
                                    primary: XCUIElement,
                                    secondary: XCUIElement) {
        // At AXXXL the sheet's content overflows the viewport by design and requires scrolling.
        // Verify that nothing is dropped from the accessibility tree — labels and both CTAs must
        // be present. Hittability of the pinned CTAs depends on sheet detent behavior at large
        // Dynamic Type sizes and is intentionally not asserted here.
        XCTAssertTrue(title.exists, "Title label must exist at AXXXL")
        XCTAssertTrue(primary.exists, "Primary button must exist at AXXXL")
        XCTAssertTrue(secondary.exists, "Secondary button must exist at AXXXL")
    }
}

// MARK: - XCUIElement helpers

private extension XCUIElement {
    /// Complement to `waitForExistence(timeout:)`; returns `true` if the element disappears in time.
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let gonePredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gonePredicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Returns `true` once the element is hittable, polling up to `timeout`. Fast-paths when
    /// already hittable so the common case is cheap.
    func waitUntilHittable(timeout: TimeInterval) -> Bool {
        if isHittable { return true }
        let hittablePredicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: hittablePredicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
