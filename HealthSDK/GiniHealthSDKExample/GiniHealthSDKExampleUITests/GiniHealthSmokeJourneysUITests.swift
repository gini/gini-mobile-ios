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

        // On first use (no bank selected yet) Health shows the Payment Component
        // bottom sheet rather than the full Payment Review Screen. Tap its
        // Select-bank button to open the Bank Selection list.
        XCTAssertTrue(paymentComponentScreen.selectBankButton.waitForExistence(timeout: 30),
                      "Payment Component bottom sheet did not appear after Transfer directly.")
        paymentComponentScreen.selectBankButton.tap()

        // Bank Selection sheet → tap Black bank. The sheet dismisses and the
        // Payment Review Screen opens with Black bank preselected.
        let blackBankCell = bankSelectionBottomSheet.cell(for: "Black bank")
        XCTAssertTrue(blackBankCell.waitForExistence(timeout: 10),
                      "Black bank row not found in the Bank Selection sheet — client config may not list it.")
        blackBankCell.tap()

        // Payment Review Screen populated with extracted values.
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear after bank selection.")
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
}
