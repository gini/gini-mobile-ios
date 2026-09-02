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

 Fixtures (shared 1:1 with Android PP-3301, uploaded by `Scripts/bs_run_payment_hint.sh`
 as PDFs so they land in Files.app "Custom_Files" and can be selected by
 `MainScreen.tapFileFromBestAvailableSource(fileName:)`):
 `invoice_future_due.pdf` → `paymentDueDate = 2028-09-01`;
 `invoice_no_due_date.pdf` → no `paymentDueDate`. The PDFs are wrapped from the
 Android JPEG sources; extraction is unchanged. Regenerate from
 `gini-mobile-android@release/bank-sdk-4.5` before mid-2028 and update
 `FIXTURE_DUE_DATE`.

 Show / no-show cases are driven by varying `-paymentDueHintThresholdDaysOverride`,
 not by refreshing the invoice.
 */
final class PaymentHintFlowUITests: GiniBankSDKExampleUITests {

    // MARK: - Fixture

    /**
     Encoded on `invoice_future_due.pdf` — validated against the real Gini API 2026-08-17.
     Parses in the device's default timezone so `remainingDays()` matches the SDK's
     `Date.isDueSoon(within:)` on UTC-configured BS devices.
     */
    private static let FIXTURE_DUE_DATE: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: "2028-09-01") else {
            preconditionFailure("FIXTURE_DUE_DATE literal must be a valid yyyy-MM-dd string")
        }
        return date
    }()

    /**
     `FIXTURE_DUE_DATE` as `dd.MM.yyyy` — locale-independent substring for title assertion.
     */
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

    /**
     Days between today and `FIXTURE_DUE_DATE`, computed like `Date.isDueSoon(within:)`.
     */
    private func remainingDays() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: Self.FIXTURE_DUE_DATE)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }

    /**
     `true` within 30 min of midnight. Skips boundary-threshold tests to avoid
     date-rollover flips (mirrors Android PP-3301).
     */
    private var isNearMidnight: Bool {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let minutesSinceMidnight = hour * 60 + minute
        return minutesSinceMidnight < 30 || minutesSinceMidnight >= 23 * 60 + 30
    }

    /**
     Relaunches with `paymentDueHintThresholdDays` set to `thresholdOverride`.
     */
    private func relaunchApp(thresholdOverride: Int) {
        extraLaunchArguments = ["-paymentDueHintThresholdDaysOverride", "\(thresholdOverride)"]
        relaunch()
    }

    /**
     Toggles both payment-hint switches via the Settings screen. Assumes main screen.
     */
    private func setPaymentHintFlags(dueDate: Bool,
                                     schedule: Bool) {
        mainScreen.configurationButton.tap()
        settingScreen.setPaymentHintFlags(dueDate: dueDate, schedule: schedule)
        settingScreen.closeButton.tap()
    }

    /**
     Runs the Photopayment flow up to (but not through) the payment-hint sheet by
     importing a PDF from Files.app. `fileName` is looked up by exact-name substring
     in Files.app "Custom_Files" (BS) or On-My-iPhone → GiniBankSDKExample (local).
     Selecting the PDF advances straight to analysis — no ReviewViewController /
     Process button step.
     */
    private func runFlowToAnalysis(fileName: String) {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        /// "Upload files" opens the Files-app picker (not the Photos picker), which is what
        /// `tapFileFromBestAvailableSource` expects — Files can be selected by exact name from
        /// BS Custom_Files or from the local On-My-iPhone GiniBankSDKExample folder.
        captureScreen.uploadFilesButton.tap()
        /// Tap Due date document.
        mainScreen.tapFileFromBestAvailableSource(fileName: fileName)
        /// "Open" button appears on some iOS versions/flows; safe to skip if absent.
        /// Selecting a PDF here goes straight into Analysis — no ReviewViewController /
        /// Process button step (matches the Skonto Files flow in GiniSkontoScreenUITests).
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
    }

    /**
     Runs the Photopayment flow via the Photos-picker path, picking the most-recently-uploaded
     image (`offset: 0` → `invoice_future_due.jpeg`). Complements `runFlowToAnalysis(fileName:)`,
     which uses Files.app. Used by the one gallery-smoke test that keeps the Photos code path
     exercised end-to-end without duplicating every R1–R13 scenario.
     */
    private func runFlowToAnalysisViaGallery() {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery(offset: 0)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 60),
                      "Process button should appear on the review screen (gallery path)")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 15)
        reviewScreen.processButton.tap()
    }

    private var extractionDoneButton: XCUIElement { app.navigationBars.buttons["Done"] }

    /**
     Confirms the SDK reached the results screen and closes back to the host's main screen.
     Dismisses the Transaction Docs alert with "only for this transaction" if it appears
     (BrowserStack always shows it on first run; local cold-installs may not).
     `waitForResults` bounds the wait for the alert — covers real Gini API extraction time.
     */
    private func assertExtractionReachesMainScreen(waitForResults: TimeInterval) {
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: waitForResults) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5),
                      "Send feedback (Done) button should appear on the results screen")
        mainScreen.sendFeedbackButton.tap()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Main screen (Photopayment button) should be reached after closing the SDK")
    }

    // MARK: - R1: Due Date Hint sheet appears

    func testDueDateSheetAppearsWithDefaultThreshold() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet(),
                      "Due Date Hint container should appear within 60 s")
        XCTAssertTrue(paymentHintScreen.dueDateTitle.label.contains(Self.FIXTURE_DUE_DATE_FORMATTED),
                      "Title label should contain the formatted due date \(Self.FIXTURE_DUE_DATE_FORMATTED)")
    }

    // MARK: - R2: Schedule Payment sheet appears (priority)

    func testScheduleSheetAppearsWhenBothFlagsOn() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet(),
                      "Schedule container should appear when both flags are on (schedule priority)")
        XCTAssertFalse(paymentHintScreen.dueDateContainer.waitForExistence(timeout: 3),
                       "Due Date container should NOT appear when schedule is enabled")
    }

    func testScheduleSheetAppearsWhenOnlyScheduleFlagOn() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: false, schedule: true)
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet(),
                      "Due Date Hint sheet should appear at boundary (threshold == remainingDays = \(boundary))")
    }

    // MARK: - R4: Below threshold — threshold > remainingDays

    func testSheetDoesNotAppearBelowThreshold() throws {
        try XCTSkipIf(isNearMidnight,
                      "Skipping below-threshold test within 30 min of midnight to avoid date-rollover flake")

        /// `isDueSoon(within: N)` fires when `daysUntilDue + 1 >= N`, so the largest firing
        /// threshold is `remainingDays + 1`. Use `remainingDays + 2` to sit strictly above it.
        relaunchApp(thresholdOverride: remainingDays() + 2)
        setPaymentHintFlags(dueDate: true, schedule: true)
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceNoDueDate)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet())

        let backdropTap = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        backdropTap.tap()

        XCTAssertTrue(paymentHintScreen.scheduleContainer.exists,
                      "Schedule container should remain visible after a backdrop tap")
        Thread.sleep(forTimeInterval: 3)
        XCTAssertTrue(paymentHintScreen.scheduleContainer.exists,
                      "Schedule container should still be visible 3 s after a backdrop tap")
    }

    // MARK: - R12: Capture-suggestions banner suppression — descoped
    //
    // The two `testCaptureSuggestions…` tests were removed. They could not verify R12
    // through this flow: (1) `CaptureSuggestionsView` is only created when
    // `document is GiniImageDocument` (`AnalysisViewController.swift:161-163`), and
    // this suite imports PDFs; (2) the SDK does not attach a stable accessibility
    // identifier to the suggestions container, so any XCUIElement query would match
    // nothing and pass vacuously. R12 remains covered by manual test until an
    // image-import fixture path and a stable identifier are added — tracked as a
    // follow-up.

    // MARK: - R13: Dynamic Type AXXXL does not truncate the sheet

    func testAXXXLDoesNotTruncateDueDateSheet() throws {
        extraLaunchArguments = [
            "-paymentDueHintThresholdDaysOverride", "5",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        relaunch()

        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet())
        assertNoTruncation(container: paymentHintScreen.dueDateContainer,
                           title: paymentHintScreen.dueDateTitle,
                           description: paymentHintScreen.dueDateDescription,
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
        runFlowToAnalysis(fileName: TestFixtures.Files.invoiceFutureDue)

        XCTAssertTrue(paymentHintScreen.waitForScheduleSheet())
        assertNoTruncation(container: paymentHintScreen.scheduleContainer,
                           title: paymentHintScreen.scheduleTitle,
                           description: paymentHintScreen.scheduleDescription,
                           primary: paymentHintScreen.scheduleButton,
                           secondary: paymentHintScreen.scheduleProceedButton)
    }

    /**
     Asserts every sheet element stays in the a11y tree at AXXXL. Hittability
     is intentionally not asserted — the sheet's `contentScrollView` overflows
     by design at Accessibility sizes and requires scrolling.
     */
    private func assertNoTruncation(container: XCUIElement,
                                    title: XCUIElement,
                                    description: XCUIElement,
                                    primary: XCUIElement,
                                    secondary: XCUIElement) {
        XCTAssertTrue(container.exists, "Sheet container must exist at AXXXL")
        XCTAssertTrue(title.exists, "Title label must exist at AXXXL")
        XCTAssertTrue(description.exists, "Description label must exist at AXXXL")
        XCTAssertTrue(primary.exists, "Primary button must exist at AXXXL")
        XCTAssertTrue(secondary.exists, "Secondary button must exist at AXXXL")
    }

    // MARK: - Gallery smoke — Photos-picker code path

    /**
     Verifies the Photos-picker + review-screen import path still reaches the payment-hint
     sheet end-to-end. Not R1–R13 coverage — those already run via the Files.app path across
     all 15 tests. This single smoke keeps the alternate import path from silently rotting.
     */
    func testDueDateSheetAppearsViaGallery() throws {
        relaunchApp(thresholdOverride: 5)
        setPaymentHintFlags(dueDate: true, schedule: false)
        runFlowToAnalysisViaGallery()

        XCTAssertTrue(paymentHintScreen.waitForDueDateSheet(),
                      "Due Date Hint container should appear within 60 s (gallery path)")
    }
}

// MARK: - XCUIElement helpers

private extension XCUIElement {
    /**
     Complement to `waitForExistence(timeout:)` — returns `true` if the element disappears in time.
     */
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let gonePredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gonePredicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
