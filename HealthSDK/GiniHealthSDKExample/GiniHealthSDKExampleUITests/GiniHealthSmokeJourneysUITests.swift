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
     Review Screen when it appears: taps Select-bank, picks any available bank,
     then taps Continue to overview (with the coordinate-tap fallback for the
     iOS 26 safe-area quirk).

     Two post-TransferDirectly paths exist:
     1. **Payment Component sheet** — first-time flow with no bank selected.
        Drive Select-bank → bank cell → Continue to overview.
     2. **Direct to Payment Review Screen** — a bank was previously selected
        (persisted across launches in the same runner session, or auto-chosen
        by extraction) and the Payment Component intermediate is skipped.

     Both paths are raced for up to ~15 s. If the Payment Review Screen opened
     directly, this returns immediately with nothing to drive; the caller still
     runs `assertPaymentReviewReachedWithPopulatedFields` to verify fields.
     */
    private func drivePaymentFlowThroughBankSelectionToPaymentReview() {
        let selectBank = paymentComponentScreen.selectBankButton
        let ibanField = paymentReviewScreen.ibanField
        let deadline = Date().addingTimeInterval(60)
        while Date() < deadline {
            if ibanField.exists {
                /// Payment Review opened directly — nothing to drive.
                return
            }
            if selectBank.exists { break }
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTAssertTrue(selectBank.exists,
                      "Neither Payment Component bottom sheet nor Payment Review Screen appeared after Transfer directly.")
        selectBank.tap()
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

     Each field value is **polled** rather than read once because the SwiftUI
     `TextField`s render immediately with their binding target
     (`viewModel.<field>InputState.text`) still empty — the viewModel's async
     load happens shortly after. HEAL-285/287 reach this screen through the
     Payment Component Select-bank → Continue path which adds a few seconds
     of natural wait, hiding the race; HEAL-282/284 reach it directly after
     Transfer directly, so a one-shot read fires `XCTAssertFalse(isEmpty)`
     before the bindings populate. 15 s per field is well over the typical
     load (<2 s) and still fails fast if the extraction model never arrived.
     */
    private func assertPaymentReviewReachedWithPopulatedFields() {
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear after Continue to overview.")
        for field in [paymentReviewScreen.ibanField,
                      paymentReviewScreen.recipientField,
                      paymentReviewScreen.amountField,
                      paymentReviewScreen.referenceField] {
            let deadline = Date().addingTimeInterval(15)
            while Date() < deadline, paymentReviewScreen.value(of: field).isEmpty {
                Thread.sleep(forTimeInterval: 0.3)
            }
            XCTAssertFalse(paymentReviewScreen.value(of: field).isEmpty,
                           "Payment Review field \(field.identifier) still empty 15 s after screen appeared — extraction model may not have arrived.")
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

        /// CaptureSDK's `GiniScreenAPICoordinator.initialViewControllers` routes
        /// imported pages by document type: images land on the Review screen
        /// (Process button), **PDFs skip Review and go directly to the Analysis
        /// screen**. HEAL-282 (image import) still calls `tapProcessOnReview`;
        /// HEAL-284 (PDF import) must not — the Process button never exists in
        /// this path and waiting for it would just time out.

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

     The Orders entry has a different flow from the Invoices entry (HEAL-285):
     the row push lands on the host app's Order Details screen
     (`OrderDetailViewController`) which carries its own Pay button. Tapping
     Pay starts the Health SDK's payment flow and opens the Payment Review
     Screen directly as a bottom sheet — the Payment Component Select-bank
     intermediate sheet is skipped. `drivePaymentFlowThroughBankSelectionToPaymentReview`
     is deliberately NOT reused here.

     The host app seeds its own orders via `HardcodedInvoicesController`.
     */
    func testOrdersListEntryShowsPaymentReview() throws {
        XCTAssertTrue(mainScreen.ordersListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.ordersListButton.tap()

        XCTAssertTrue(ordersListScreen.waitForFirstRow(timeout: 60),
                      "Orders list did not populate with a hardcoded order — HardcodedInvoicesController seed may have failed or timed out.")
        ordersListScreen.firstRow.tap()

        orderDetailsScreen.tapPay()
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

        /// Expect one of: the app backgrounded (deeplink succeeded) or the
        /// Install App bottom sheet appeared (bank not installed on this device).
        /// Either signals the handoff was attempted. If neither occurs within
        /// 10 s the pay-tap silently did nothing — a regression worth flagging.
        ///
        /// The sheet's accessibility identifiers are not set upstream
        /// (`InstallAppBottomView` in `GiniInternalPaymentSDK`), so we match on
        /// stable phrases from its localised strings:
        ///   - button "Forward" (EN) / "Weiter" (DE) — unique to this sheet.
        ///   - note containing "install" (EN) / "installieren" (DE) — covers
        ///     both locales via `CONTAINS[c]`.
        ///   - the "App Store" / "App-Store" footer label.
        let installPhraseAny = app.descendants(matching: .any)
            .matching(NSPredicate(format:
                "label CONTAINS[c] 'install' OR label CONTAINS[c] 'App Store' OR label CONTAINS[c] 'App-Store'"))
            .firstMatch
        let forwardButton = app.buttons
            .matching(NSPredicate(format: "label IN %@", ["Forward", "Weiter"]))
            .firstMatch
        let appStateDeadline = Date().addingTimeInterval(10)
        var handoffDetected = false
        while Date() < appStateDeadline {
            if app.state == .runningBackground || app.state == .runningBackgroundSuspended || app.state == .notRunning {
                handoffDetected = true
                break
            }
            if forwardButton.exists || installPhraseAny.exists {
                handoffDetected = true
                break
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTAssertTrue(handoffDetected,
                      "Pay button tap did not produce a handoff signal (no app background, no Install App bottom sheet) within 10 s.")
    }
}
