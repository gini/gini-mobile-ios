//
//  GiniHealthSmokeJourneysUITests.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 End-to-end journey smoke tests mapped from the HEAL Xray SmokeTestSuite
 folder (`/Health SDK Test Cases/SmokeTestSuite`).

 Each test method targets one Xray row; the HEAL ticket number is kept in
 the method's docstring (not the method name) so failures surface with a
 descriptive, grep-friendly name and reviewers map back to Xray via the
 inline reference.

 The suite runs on BrowserStack under `singleRunnerInvocation: "true"`
 (set in `bs_run_smoke_journeys.sh`) so the per-test setup overhead is
 paid once. Tests that depend on BrowserStack-staged media guard with
 `#if targetEnvironment(simulator) throw XCTSkip` so the suite still runs
 locally against the simulator-safe subset.
 */
final class GiniHealthSmokeJourneysUITests: GiniHealthSDKExampleUITests {

    // MARK: - Shared flow helpers

    /**
     Drives the modal Payment Component sheet all the way to the Payment
     Review Screen: taps Select-bank, picks any available bank, then taps
     Continue to overview (with the coordinate-tap fallback for the
     iOS 26 safe-area quirk).

     Assumes the modal Payment Component bottom sheet is already visible —
     i.e. the test has already tapped Transfer directly or the equivalent
     entry trigger. On return, the Payment Review Screen has started
     opening (fields may still be loading).
     */
    private func drivePaymentFlowThroughBankSelectionToPaymentReview() {
        XCTAssertTrue(paymentComponentScreen.selectBankButton.waitForExistence(timeout: 60),
                      "Payment Component bottom sheet did not appear after Transfer directly.")
        paymentComponentScreen.selectBankButton.tap()
        let bankCell = bankSelectionBottomSheet.anyBankCell
        XCTAssertTrue(bankCell.waitForExistence(timeout: 10),
                      "No bank cells found in the Bank Selection sheet — Select-bank tap may not have opened the sheet, or client config returned no payment providers.")
        bankCell.tap()
        XCTAssertTrue(paymentComponentScreen.continueToOverviewButton.waitForExistence(timeout: 10),
                      "Continue to overview button did not appear on the Payment Component after bank selection.")
        paymentComponentScreen.tapContinueToOverview()
    }

    /**
     Asserts the Payment Review Screen reached, all four payment fields
     (IBAN, Recipient, Amount, Reference) carry non-empty extracted
     values, and the Pay button is reachable (handoff setup is complete).

     Values are not asserted literally — the smoke suite only verifies
     that the pipeline landed on Payment Review with a populated model;
     specific-value coverage lives in `GiniHealthSDKExampleTests`
     integration tests.
     */
    private func assertPaymentReviewReachedWithPopulatedFields() {
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear after Continue to overview.")
        for field in [paymentReviewScreen.ibanField,
                      paymentReviewScreen.recipientField,
                      paymentReviewScreen.amountField,
                      paymentReviewScreen.referenceField] {
            XCTAssertFalse(paymentReviewScreen.value(of: field).isEmpty,
                           "Payment Review field \(field.identifier) is empty after extraction.")
        }
        XCTAssertTrue(paymentReviewScreen.payButton.waitForExistence(timeout: 10),
                      "Pay button not reachable after bank selection — handoff setup incomplete.")
    }

    // MARK: - HEAL-282 — Image gallery import

    /**
     HEAL-282 — "Verify Import invoice image extracts IBAN, Recipient,
     Amount and Reference correctly in Payment Review Screen and Black bank".

     Device-only: needs an invoice PNG in the Photos library, which
     BrowserStack stages via `uploadMedia`. The simulator has no equivalent;
     use `testInvoicesListEntryShowsPaymentReview` locally instead.
     */
    func testImageImportExtractsAndShowsPaymentReview() throws {
        #if targetEnvironment(simulator)
            throw XCTSkip("HEAL-282 requires a Photos-library invoice (BrowserStack-staged); use Invoices-List entry locally.")
        #endif

        XCTAssertTrue(mainScreen.startWithGiniCaptureButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.startWithGiniCaptureButton.tap()
        mainScreen.handleSystemPermission(answer: true)

        captureImportFlow.skipOnboardingIfPresented()
        captureImportFlow.tapImportThenPhotoLibrary()
        mainScreen.handleSystemPermission(answer: true)
        captureImportFlow.pickLatestPhoto()
        captureImportFlow.tapProcessOnReview()

        XCTAssertTrue(invoicesListScreen.transferDirectlyButton.waitForExistence(timeout: 60),
                      "Invoices List did not appear with the imported invoice — extraction may have failed or timed out.")
        invoicesListScreen.transferDirectlyButton.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()
        assertPaymentReviewReachedWithPopulatedFields()
    }

    // MARK: - HEAL-284 — PDF import via Files app

    /**
     HEAL-284 — "Verify Import invoice PDF extracts IBAN, Recipient, Amount
     and Reference correctly in Payment Review Screen and Black bank".

     Enters through CaptureSDK's Files → Upload files path and picks
     `testMedInvoice.pdf` from the system Files picker. BrowserStack stages
     the PDF in Custom_Files; the local simulator stages it in the app's
     Documents folder via `copyFixturesToSimulator` (base class setUp).
     */
    func testPDFImportExtractsAndShowsPaymentReview() throws {
        XCTAssertTrue(mainScreen.startWithGiniCaptureButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.startWithGiniCaptureButton.tap()
        mainScreen.handleSystemPermission(answer: true)

        captureImportFlow.skipOnboardingIfPresented()
        captureImportFlow.tapImportThenFiles()
        captureImportFlow.pickPDFFromFilesPicker(fileName: TestFixtures.Files.medInvoice)
        captureImportFlow.tapProcessOnReview()

        XCTAssertTrue(invoicesListScreen.transferDirectlyButton.waitForExistence(timeout: 60),
                      "Invoices List did not appear with the imported PDF — extraction may have failed or timed out.")
        invoicesListScreen.transferDirectlyButton.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()
        assertPaymentReviewReachedWithPopulatedFields()
    }

    // MARK: - HEAL-285 — Invoices List entry

    /**
     HEAL-285 — "Verify Invoice list from main entry point extracts IBAN,
     Recipient, Amount and Reference correctly in Payment Review Screen and
     Black bank".

     Local-friendly: skips the camera/gallery dance entirely. The host app's
     `HardcodedInvoicesController` uploads bundled invoice files to the
     Gini API on launch; the first row appears once the first extraction
     completes.

     Run from the command line against a booted simulator:

     ```bash
     xcodebuild test \
       -workspace GiniMobile.xcworkspace \
       -scheme GiniHealthSDKExample \
       -destination 'platform=iOS Simulator,name=iPhone 16' \
       -only-testing:GiniHealthSDKExampleUITests/GiniHealthSmokeJourneysUITests/testInvoicesListEntryShowsPaymentReview \
       CODE_SIGNING_ALLOWED=NO
     ```
     */
    func testInvoicesListEntryShowsPaymentReview() throws {
        XCTAssertTrue(mainScreen.invoicesListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.invoicesListButton.tap()

        invoicesListScreen.seedIfEmpty()
        invoicesListScreen.transferDirectlyButton.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()
        assertPaymentReviewReachedWithPopulatedFields()
    }

    // MARK: - HEAL-286 — Orders list entry

    /**
     HEAL-286 — "Verify Orders list invoice entry point extracts IBAN,
     Recipient, Amount and Reference correctly in Payment Review Screen and
     Black bank".

     Mirror of HEAL-285 using the Orders-list entry button instead of the
     Invoices-list button. The host app's Orders flow seeds its own
     hardcoded documents via `HardcodedInvoicesController`.
     */
    func testOrdersListEntryShowsPaymentReview() throws {
        XCTAssertTrue(mainScreen.ordersListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.ordersListButton.tap()

        /// Orders list rows are tapped directly — no per-row Transfer directly
        /// button like the Invoices list has. Pick the first row to open the
        /// Payment Component bottom sheet.
        XCTAssertTrue(ordersListScreen.waitForFirstRow(timeout: 60),
                      "Orders list did not populate with a hardcoded order — HardcodedInvoicesController seed may have failed or timed out.")
        ordersListScreen.firstRow.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()
        assertPaymentReviewReachedWithPopulatedFields()
    }

    // MARK: - HEAL-287 — GPC (Gini Pay Connect) flow

    /**
     HEAL-287 — "Verify GPC flow with Black bank extracts IBAN, Recipient,
     Amount and Reference correctly in Payment Review Screen and Black bank".

     Every Health SDK example-app payment path uses GPC under the hood —
     this test exercises the GPC flow via the Invoices-list entry (the
     simplest reliable reproduction path on both BrowserStack and the
     simulator) and verifies the full pipeline reaches Payment Review with
     extracted values. The "Black bank" branding in the HEAL title refers
     to any bank with GPC-supported deeplinks; `anyBankCell` picks whatever
     the client's provider list surfaces.
     */
    func testGPCFlowShowsPaymentReview() throws {
        XCTAssertTrue(mainScreen.invoicesListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.invoicesListButton.tap()

        invoicesListScreen.seedIfEmpty()
        invoicesListScreen.transferDirectlyButton.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()
        assertPaymentReviewReachedWithPopulatedFields()
    }

    // MARK: - HEAL-293 — Edit payment fields

    /**
     HEAL-293 — "Verify updated IBAN, Recipient, Amount and Reference values
     are reflected correctly in the Black bank from the Payment Review Screen".

     Smoke-level verification: reach Payment Review via the Invoices-list
     entry, tap the IBAN field to focus it, type additional characters, and
     verify the field value changed. The full "propagate to Black bank"
     assertion needs a real banking app installed to receive the handoff
     and is out of smoke scope — see the integration suite for that.
     */
    func testEditPaymentFieldsPersistInPaymentReview() throws {
        XCTAssertTrue(mainScreen.invoicesListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.invoicesListButton.tap()

        invoicesListScreen.seedIfEmpty()
        invoicesListScreen.transferDirectlyButton.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()

        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear — cannot verify field edits.")

        let originalIBAN = paymentReviewScreen.value(of: paymentReviewScreen.ibanField)
        XCTAssertFalse(originalIBAN.isEmpty,
                       "IBAN field is empty before edit — extraction may have failed.")

        /// Focus and append a sentinel to the IBAN. Not using `clearAndType` because
        /// SwiftUI TextField selection semantics vary across iOS 15–26; appending
        /// is sufficient to prove the field accepts input.
        paymentReviewScreen.ibanField.tap()
        paymentReviewScreen.ibanField.typeText("00")

        let editedIBAN = paymentReviewScreen.value(of: paymentReviewScreen.ibanField)
        XCTAssertNotEqual(originalIBAN, editedIBAN,
                          "IBAN field value did not change after typing — the field may not be editable.")
    }

    // MARK: - HEAL-304 — Pay button triggers bank handoff

    /**
     HEAL-304 — "Verify invoice payment status is updated after payment is
     completed in the banking app".

     Device-only: the handoff attempts a URL scheme / Install App bottom
     sheet that the simulator cannot complete. Verifies the smoke-level
     part of the flow: reach Payment Review, tap Pay, confirm the app
     either backgrounded (deeplink succeeded) or presented the Install App
     bottom sheet (bank not installed). Full "status updates to PAID" is
     out of smoke scope — needs a real banking app on the test device.
     */
    func testPayButtonTriggersBankHandoff() throws {
        #if targetEnvironment(simulator)
            throw XCTSkip("HEAL-304 bank handoff needs a device with a bank app; simulator cannot complete the flow.")
        #endif

        XCTAssertTrue(mainScreen.invoicesListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.invoicesListButton.tap()

        invoicesListScreen.seedIfEmpty()
        invoicesListScreen.transferDirectlyButton.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()
        XCTAssertTrue(paymentReviewScreen.payButton.waitForExistence(timeout: 30),
                      "Pay button not reachable — Payment Review Screen may not have loaded.")

        paymentReviewScreen.payButton.tap()

        /// Expect one of: the app backgrounded (deeplink succeeded) or an Install
        /// App bottom sheet appeared (bank not installed on this device). Either
        /// signals the handoff was attempted. If neither occurs within 10 s the
        /// pay-tap silently did nothing — a regression worth flagging.
        let appStateDeadline = Date().addingTimeInterval(10)
        var handoffDetected = false
        while Date() < appStateDeadline {
            if app.state == .runningBackground || app.state == .runningBackgroundSuspended || app.state == .notRunning {
                handoffDetected = true
                break
            }
            let installAppIndicator = app.staticTexts["Install App"].firstMatch
            if installAppIndicator.exists {
                handoffDetected = true
                break
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTAssertTrue(handoffDetected,
                      "Pay button tap did not produce a handoff signal (no app background, no Install App sheet) within 10 s.")
    }
}
