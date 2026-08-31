//
//  GiniCreditNoteScreenUITests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 UI tests for the Credit Note Warning flow.

 Preconditions:
 - The `credit_note` fixture (PDF for the Files path, PNG for the gallery path) must be
   available on the device. On BrowserStack, upload it via `Scripts/bs_run_credit_note.sh`.
   The Gini backend must classify the document as `businessDocType == "creditnote"`.
 - The backend client configuration flag `creditNoteHintEnabled` must be enabled for the
   test client credentials — the warning is gated on BOTH the SDK flag and the backend flag.

 Locale note: the English and German cases are covered by the same
 test methods — element lookup is locale-driven through `CreditNoteWarningScreen`, so a run
 with the device language set to German exercises the German case.

 The Charles-dependent flag matrix is automated
 separately in the `GiniCreditNoteMockBackend*UITests` classes via the `UITestMockBackend` launch
 arguments — no proxy needed. The VoiceOver/external-keyboard accessibility cases remain
 manual; XCUITest cannot drive them on BrowserStack.
 */
class GiniCreditNoteScreenUITests: GiniBankSDKExampleUITests {

    // MARK: - Flow helpers

    /**
     Starts the photo payment flow: grants camera access and skips onboarding.
     */
    private func startPhotoPaymentFlow() {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
    }

    /**
     Full path from the main screen to a visible Credit Note Warning sheet, using the
     shared `uploadDocumentViaFilesAndAwaitAnalysis(fileName:)` journey.
     */
    private func reachCreditNoteWarning() {
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.creditNote)
        XCTAssertTrue(creditNoteWarningScreen.waitForDialog(timeout: 15),
                      "Credit Note Warning sheet did not appear after analysis — check that the fixture is classified as a credit note and the backend flag is enabled.")
    }

    /**
     Dismisses the optional transaction docs alert and asserts the Transfer Summary screen.
     */
    private func passTransactionDocsAlertAndAssertSummary() {
        // Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        transactionSummaryScreen.assertExtractionsAreDisplayed()
    }

    // MARK: - Tests

    /**
     The `creditNoteHintEnabled` SDK feature flag is ON by default.
     */
    func testCreditNoteFlagIsEnabledByDefault() {
        // Open the settings screen
        mainScreen.configurationButton.tap()
        // Scroll to the credit note hint switch and assert it is ON by default
        let creditNoteSwitch = settingScreen.switchInCell(containing: settingScreen.creditNoteHintCellText)
        XCTAssertEqual((creditNoteSwitch.value as? String) ?? "", "1",
                       "Expected the credit note hint feature flag to be ON by default.")
        // Close settings
        settingScreen.closeButton.tap()
        // Assert the main screen is back
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }

    /**
     The Credit Note Warning sheet appears after analysing a credit note
     uploaded via the Files picker, with both action buttons.
     */
    func testCreditNoteWarningDialogIsDisplayedViaFiles() {
        reachCreditNoteWarning()
        // Assert both actions are tappable
        XCTAssertTrue(creditNoteWarningScreen.cancelTransferButton.isHittable)
        XCTAssertTrue(creditNoteWarningScreen.proceedAnywayButton.isHittable)
    }

    /**
     Gallery path: the Credit Note Warning sheet appears after analysing
     a credit note image imported from the photo gallery.

     Pre-condition: the `credit_note` PNG must be the most recently added photo in the gallery.
     */
    func testCreditNoteWarningDialogIsDisplayedViaGallery() {
        startPhotoPaymentFlow()
        // Import the credit note image from the photo gallery
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()
        // Wait for ReviewViewController and tap Process to trigger analysis
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton)
        reviewScreen.processButton.tap()
        waitForAnalysisIfNeeded()
        // Assert the warning sheet appeared
        XCTAssertTrue(creditNoteWarningScreen.waitForDialog(timeout: 15),
                      "Credit Note Warning sheet did not appear after analysing the gallery image.")
    }

    /**
     The Credit Note Warning sheet cannot be dismissed by tapping
     outside its buttons.
     */
    func testCreditNoteWarningCannotBeDismissedByTappingOutside() {
        reachCreditNoteWarning()
        // Tap the dimmed area above the sheet
        creditNoteWarningScreen.tapOutsideDialog()
        // Assert the sheet never disappears — waiting for non-existence to time out rules out
        // a pass during a dismissal animation.
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"),
                                             object: creditNoteWarningScreen.title)
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: 3), .timedOut,
                       "Credit Note Warning sheet was dismissed by tapping outside its buttons.")
        XCTAssertTrue(creditNoteWarningScreen.cancelTransferButton.isHittable)
        XCTAssertTrue(creditNoteWarningScreen.proceedAnywayButton.isHittable)
    }

    /**
     "Cancel transfer" closes the capture flow and returns the user
     to the screen where the flow was started.
     */
    func testCreditNoteWarningCancelTransferClosesSDK() {
        reachCreditNoteWarning()
        // Cancel the transfer
        creditNoteWarningScreen.cancelTransferButton.tap()
        // Assert the host app main screen is back
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10),
                      "Expected to return to the host app main screen after cancelling the transfer.")
    }

    /**
     "Proceed anyway" continues to the extraction
     results. The recipient is filled in; `amountToPay` stays empty because the SDK
     strips it from a credit note result. The IBAN is not asserted — the credit note
     fixture carries no IBAN.
     */
    func testCreditNoteWarningProceedAnywayShowsExtractions() {
        reachCreditNoteWarning()
        // Proceed despite the warning
        creditNoteWarningScreen.proceedAnywayButton.tap()
        passTransactionDocsAlertAndAssertSummary()
        // The amount must be stripped from a credit note result — the demo app still renders
        // the row (it appends empty rows for missing editable extractions), but with no value.
        // The value text field has no placeholder, so an empty field reads as "".
        let amountValue = transactionSummaryScreen.extractionValue(named: "amountToPay")
        XCTAssertTrue(amountValue.isEmpty,
                      "Expected amountToPay to be empty for a credit note, got '\(amountValue)'.")
        // Submit the transfer summary and assert the SDK closed
        transactionSummaryScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10))
    }

    /**
     Flag gate: with the `creditNoteHintEnabled` SDK flag OFF, a credit note is processed
     like a regular invoice — no warning sheet.
     */
    func testCreditNoteWarningNotShownWhenHintFlagDisabled() {
        // Disable the credit note hint feature flag in settings
        disableCreditNoteSdkFlag()
        // Run the capture flow with the credit note document
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.creditNote)
        // Assert the credit note warning never appeared
        XCTAssertFalse(creditNoteWarningScreen.title.exists,
                       "Credit Note Warning must not appear when the SDK feature flag is disabled.")
        // Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        transactionSummaryScreen.assertExtractionsAreDisplayed()
    }

    /**
     With the flag OFF, a regular invoice with a feature
     screen (Skonto) flows through unaffected and never shows the credit note warning.
     */
    func testInvoiceFlowUnaffectedWhenHintFlagDisabled() {
        // Disable the credit note hint feature flag in settings
        disableCreditNoteSdkFlag()
        // Upload a Skonto invoice
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.skontoPast)
        // Assert the invoice-specific screen (Skonto) is displayed instead of the warning
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 15),
                      "Expected the Skonto screen for a regular invoice.")
        XCTAssertFalse(creditNoteWarningScreen.title.exists,
                       "Credit Note Warning must not appear for a regular invoice.")
    }
}

/**
 Accessibility variant: runs the "Proceed anyway" journey with the app's
 content size forced to an accessibility text size (~200% of the default body size) and
 attaches named screenshots at the decision points. The "no distorted/overlapping text"
 acceptance stays a visual check on the BrowserStack dashboard.
 */
class GiniCreditNoteDynamicTypeUITests: GiniBankSDKExampleUITests {

    override var additionalLaunchArguments: [String] {
        ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL"]
    }

    /**
     Attaches a screenshot that survives a passing run, for visual review on BrowserStack.
     */
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testCreditNoteWarningProceedAnywayAt200PercentFont() {
        // Start the flow and upload the credit note
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.creditNote)
        // Assert the warning renders with both buttons reachable at the enlarged text size
        XCTAssertTrue(creditNoteWarningScreen.waitForDialog(timeout: 15))
        XCTAssertTrue(creditNoteWarningScreen.cancelTransferButton.isHittable)
        XCTAssertTrue(creditNoteWarningScreen.proceedAnywayButton.isHittable)
        attachScreenshot(named: "credit-note-warning-200-percent-font")
        // Proceed and assert the summary renders
        creditNoteWarningScreen.proceedAnywayButton.tap()
        // Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        transactionSummaryScreen.assertExtractionsAreDisplayed()
        attachScreenshot(named: "credit-note-extractions-200-percent-font")
    }
}
