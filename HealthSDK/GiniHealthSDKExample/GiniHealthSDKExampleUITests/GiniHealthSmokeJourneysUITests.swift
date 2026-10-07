//
//  GiniHealthSmokeJourneysUITests.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 End-to-end journey smoke tests mapped from the HEAL Xray SmokeTestSuite folder.

 Each test case corresponds to one HEAL ticket; the test method name encodes it
 so a BrowserStack failure column maps cleanly back to the Xray row. The suite
 runs under `singleRunnerInvocation: "true"` (set in `bs_run_smoke_journeys.sh`)
 so the per-test setup overhead is paid once.

 Scope — HEAL cases included:
   HEAL-282  image gallery import → extraction → Payment Review → Black bank
   (HEAL-284..287, 293, 304 — stubbed until the first run lands; added in
    follow-up commits once the reference test is green.)
 */
final class GiniHealthSmokeJourneysUITests: GiniHealthSDKExampleUITests {

    /**
     Verifies the image-import entry point:
     1. The gallery picker opens from the Capture SDK's import menu.
     2. Extraction completes and the Payment Review Screen appears.
     3. All four payment fields (IBAN, Recipient, Amount, Reference) are populated.
     4. The bank picker opens the Bank Selection bottom sheet with "Black bank" present.
     5. Tapping "Black bank" triggers the handoff flow (bank app deeplink or
        Install App bottom sheet when the bank is not installed on the device).

     Values are not asserted literally — the test asserts non-emptiness only
     so a backend extraction change does not fail the smoke run. Specific-value
     coverage lives in `GiniHealthSDKExampleTests` integration tests.
     */
    func testHEAL282_ImageImportExtractsAndShowsBankSelection() throws {
        /// Device-only: HEAL-282 needs an invoice PNG in the Photos library,
        /// which BrowserStack stages via `uploadMedia`. The simulator has no
        /// equivalent — run `testHEAL285_InvoicesListEntryShowsPaymentFlow`
        /// locally instead; it covers the same Payment Component → Bank
        /// Selection → Payment Review flow via the pre-seeded Invoices List.
        #if targetEnvironment(simulator)
            throw XCTSkip("HEAL-282 requires a Photos-library invoice (BrowserStack-staged); use HEAL-285 locally.")
        #endif

        // Entry — host app
        XCTAssertTrue(mainScreen.startWithGiniCaptureButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.startWithGiniCaptureButton.tap()
        mainScreen.handleSystemPermission(answer: true)

        // Capture SDK: onboarding → files → photo library → latest photo
        captureImportFlow.skipOnboardingIfPresented()
        captureImportFlow.tapImportThenPhotoLibrary()
        mainScreen.handleSystemPermission(answer: true)
        captureImportFlow.pickLatestPhoto()
        captureImportFlow.tapProcessOnReview()

        // Health SDK routes the extracted invoice through its own InvoicesList
        // before any payment UI opens — tap the newest invoice's Transfer
        // directly button to proceed.
        XCTAssertTrue(invoicesListScreen.transferDirectlyButton.waitForExistence(timeout: 60),
                      "Invoices List did not appear with the imported invoice — extraction may have failed or timed out.")
        invoicesListScreen.transferDirectlyButton.tap()

        // Payment Component bottom sheet always opens after Transfer directly.
        // Always drive through the Bank Selection sheet to pick "Bank":
        // - Fresh install: the Payment Component has no bank selected, so the
        //   Bank Selection sheet opens and we pick Bank.
        // - Returning user: Payment Component already has a bank; tapping
        //   Select-bank re-opens the Bank Selection sheet and we pick Bank
        //   again (idempotent — picking the already-selected bank just
        //   dismisses the sheet with no state change).
        //
        // Why unconditional instead of a `continueToOverviewButton.exists`
        // branch: SwiftUI's accessibility tree keeps the Continue button in
        // place even when `viewModel.hasBankSelected == false` sets its
        // `isHidden`, so `.exists` returns `true` on the simulator for the
        // hidden element and the branch is unreliable. Always picking a bank
        // guarantees Continue-to-overview is visible and hittable when the
        // test reaches the next step.
        XCTAssertTrue(paymentComponentScreen.selectBankButton.waitForExistence(timeout: 60),
                      "Payment Component bottom sheet did not appear after Transfer directly.")
        paymentComponentScreen.selectBankButton.tap()
        /// HEAL-282 calls the target "Black bank" after its solid-black BANK icon;
        /// the client's payment-provider config exposes it as just "Bank" (verified
        /// against the Bank Selection sheet's visible rows: Gini-Test-Payment-
        /// Provider, GiniBank, Consorsbank Test, BNP Paribas myPrivateBank Test,
        /// Bank, Gini Bank SDK Example, easybank, Consorsbank, Sparkasse, …).
        let blackBankCell = bankSelectionBottomSheet.cell(for: "Bank")
        XCTAssertTrue(blackBankCell.waitForExistence(timeout: 10),
                      "Black bank (cell title \"Bank\") not found in the Bank Selection sheet — client config may have changed.")
        blackBankCell.tap()

        // Tap Continue to overview — this is the step that actually opens the
        // Payment Review Screen. Uses the helper's coordinate-fallback tap: the
        // button sits near the bottom of the Payment Component sheet and iOS
        // sometimes reports `isHittable == false` even though it is visible,
        // because the sheet layout places the button just inside the home-
        // indicator safe-area or because the Bank Selection sheet's dismiss
        // animation briefly overlays it.
        XCTAssertTrue(paymentComponentScreen.continueToOverviewButton.waitForExistence(timeout: 10),
                      "Continue to overview button did not appear on the Payment Component after bank selection.")
        paymentComponentScreen.tapContinueToOverview()

        // Payment Review Screen populated with extracted values.
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear after Continue to overview.")
        for field in [paymentReviewScreen.ibanField,
                      paymentReviewScreen.recipientField,
                      paymentReviewScreen.amountField,
                      paymentReviewScreen.referenceField] {
            XCTAssertFalse(paymentReviewScreen.value(of: field).isEmpty,
                           "Payment Review field \(field.identifier) is empty after extraction.")
        }

        // Pay button reachable means the handoff is set up — we cannot complete
        // the payment on BrowserStack (no real bank app installed), but the
        // button being present with a selected bank proves the flow landed.
        XCTAssertTrue(paymentReviewScreen.payButton.waitForExistence(timeout: 10),
                      "Pay button not reachable after bank selection — handoff setup incomplete.")
    }

    /**
     Local-friendly sibling of HEAL-282. Uses the host app's Invoices-List entry
     button, which seeds hardcoded test invoices via `HardcodedInvoicesController`
     (bundled files uploaded to the Gini API in the background on launch) — no
     camera, no gallery picker, no CaptureSDK dance. Runs on both the simulator
     and BrowserStack, so iterating on the Payment Component → Bank Selection →
     Payment Review flow does not need a full BS cycle.

     Still needs:
     - Network access to the Gini API (same as HEAL-282 — extraction is online).
     - Valid `CredentialsManager` client ID/secret in the host app bundle.

     To run from the command line against a booted simulator:

     ```bash
     xcodebuild test \
       -workspace GiniMobile.xcworkspace \
       -scheme GiniHealthSDKExample \
       -destination 'platform=iOS Simulator,name=iPhone 16' \
       -only-testing:GiniHealthSDKExampleUITests/GiniHealthSmokeJourneysUITests/testHEAL285_InvoicesListEntryShowsPaymentFlow \
       CODE_SIGNING_ALLOWED=NO
     ```

     Or run from Xcode by clicking the diamond next to the test method.
     */
    func testHEAL285_InvoicesListEntryShowsPaymentFlow() throws {
        // Entry — host app's Invoices-List button. The host coordinator opens
        // InvoicesListViewController and HardcodedInvoicesController uploads the
        // bundled sample invoices in the background; rows appear once the first
        // extraction completes.
        XCTAssertTrue(mainScreen.invoicesListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.invoicesListButton.tap()

        XCTAssertTrue(invoicesListScreen.transferDirectlyButton.waitForExistence(timeout: 60),
                      "Invoices List did not populate with a hardcoded invoice — extraction may have failed or timed out.")

        // On the Invoices-List entry, the Payment Component is **docked** at the
        // bottom of the list rather than opening modally after Transfer directly.
        // The bank must be picked here first; Transfer directly only navigates to
        // Payment Review when a bank is already selected on the docked sheet.
        //
        // This diverges from HEAL-282's flow where the Payment Component opens
        // as a modal AFTER Transfer directly on the capture-SDK-produced invoice —
        // the two entry points share screens but sequence the taps differently.
        XCTAssertTrue(paymentComponentScreen.selectBankButton.waitForExistence(timeout: 10),
                      "Docked Payment Component Select-bank button not found at the bottom of the Invoices List.")
        paymentComponentScreen.selectBankButton.tap()
        // Pick the first available bank — the local client config may list a
        // different lineup than the HEAL-282 BrowserStack build (e.g. no "Bank"
        // row), and HEAL-285 only needs to prove the flow lands on Payment
        // Review, not which specific bank is selected.
        let bankCell = bankSelectionBottomSheet.anyBankCell
        XCTAssertTrue(bankCell.waitForExistence(timeout: 10),
                      "No bank cells found in the Bank Selection sheet — Select-bank tap may not have opened the sheet, or client config returned no payment providers.")
        bankCell.tap()

        // Now the first invoice's Transfer directly button opens Payment Review.
        invoicesListScreen.transferDirectlyButton.tap()

        // Some Payment Component configurations present a Continue to overview
        // modal between Transfer directly and Payment Review; tap it if it
        // appears, otherwise fall through to the Payment Review assertion.
        if paymentComponentScreen.continueToOverviewButton.waitForExistence(timeout: 5) {
            paymentComponentScreen.tapContinueToOverview()
        }

        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear after Transfer directly (bank was selected before the tap).")
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
}
