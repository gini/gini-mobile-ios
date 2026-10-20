//
//  GiniHealthSmokeScreensUITests.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Per-screen UI smoke tests mapped from the HEAL Xray SmokeTestSuite
 folder (`/Health SDK Test Cases/SmokeTestSuite`), covering the 16 cases
 that complement the end-to-end journeys in
 `GiniHealthSmokeJourneysUITests`.

 Each test method targets one Xray row; the HEAL ticket number is kept in
 the method's docstring (not the method name) so failures surface with a
 descriptive, grep-friendly name and reviewers map back to Xray via the
 inline reference.

 The suite runs on BrowserStack via `bs_run_smoke_screens.sh` which pairs
 with `bs_run_smoke_journeys.sh` — together they cover the full
 automatable smoke subset. Each method starts with an `XCTSkip` sentinel
 so a scaffold-only merge compiles and reports every planned test as
 "skipped (pending implementation)" rather than failing.

 ## Scope split
 - Bank Selection sheet          HEAL-288, 289, 290
 - More Info / Payment Feature   HEAL-291, 292
 - Payment Review Screen         HEAL-294, 295, 296, 297, 298, 299, 300, 301, 306
 - Install App bottom sheet      HEAL-303
 - Open With / Share with        HEAL-305

 ## Explicitly manual (not here)
 - HEAL-283  Live camera QR scan — camera-only entry
 - HEAL-302  No-network default error — BrowserStack blocks WiFi toggling

 ## Lessons already captured in the journey suite — reuse, don't rediscover
 - **Payment Review entry:** use the shared
   `drivePaymentFlowThroughBankSelectionToPaymentReview` helper from
   `GiniHealthSmokeJourneysUITests`. It races `paymentComponent.selectBank`
   against `paymentReview.iban` and handles both the first-time Payment
   Component path and the direct-to-Payment-Review path (previously selected
   bank persists across launches in `singleRunnerInvocation` runs).
 - **Field reads:** poll — don't read once. SwiftUI `TextField`s render
   immediately with their `viewModel.*InputState.text` bindings still empty;
   `assertPaymentReviewReachedWithPopulatedFields` polls each field up to 15s.
   Pattern: `while Date() < deadline, value.isEmpty { Thread.sleep(0.3) }`.
 - **PDF import skips the Review screen.** `GiniScreenAPICoordinator.initialViewControllers`
   routes `.image` to Review and anything else straight to Analysis. HEAL-294
   must NOT call `tapProcessOnReview` — there is no Process button in the
   PDF path.
 - **Files picker (HEAL-294):** `pickPDFFromFilesPicker` is adaptive — BS
   `Custom_Files` vs local `On My iPhone → GiniHealthSDKExample` — and taps
   the nav-bar `Open` / `Öffnen` after the file label is selected. Tapping
   the label alone only selects (blue checkmark); it never confirms.
 - **System permissions:** `handleSystemPermission` queries both SpringBoard
   AND the host app. iOS 17+ `PHPickerViewController` limited-access consent
   is presented in-process.
 - **Install App bottom sheet (HEAL-303):** `InstallAppBottomView` has no
   literal "Install App" text and no accessibility identifier. Match on
   stable localised phrases — `Forward` / `Weiter` button, OR element
   containing `install` / `installieren` / `App Store` / `App-Store`. See
   HEAL-304 in the journey suite for the exact predicate.
 */
final class GiniHealthSmokeScreensUITests: GiniHealthSDKExampleUITests {

    // MARK: - Bank Selection sheet (HEAL-288, 289, 290)

    /**
     HEAL-288 — Bank Selection sheet renders the configured provider list.

     Reaches the Payment Review Screen via the Invoices-List entry (adaptive
     helper handles both first-time and persisted-bank paths), then taps the
     Payment Review bank picker to open the Bank Selection sheet and asserts
     at least one `bankSelection.cell.*` row is present.
     */
    func testBankSelectionSheetShowsProviders() throws {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(paymentReviewScreen.bankPickerButton.waitForExistence(timeout: 10),
                      "Payment Review bank picker not reachable after bank selection.")
        paymentReviewScreen.bankPickerButton.tap()
        XCTAssertTrue(bankSelectionBottomSheet.waitForProviders(),
                      "Bank Selection sheet did not render any provider cells after 30 s (identifier starts with 'bankSelection.cell.').")
    }

    /**
     HEAL-289 — Picking a bank from the Bank Selection sheet dismisses the
     sheet and the Payment Review Screen's bank picker reflects the choice.

     Reaches Payment Review, opens the sheet, picks an *unselected* bank
     (tapping the already-selected row still dismisses the sheet, which
     would false-pass the test even if the selection pipeline were broken),
     captures its identifier, verifies the sheet dismissed and Pay stayed
     reachable, then reopens the sheet and asserts the same bank is now
     marked `.selected` — proving the choice persisted into the Payment
     Component / provider state.
     */
    func testBankSelectionSheetSelectionUpdatesPaymentComponent() throws {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(paymentReviewScreen.bankPickerButton.waitForExistence(timeout: 10),
                      "Payment Review bank picker not reachable after bank selection.")
        paymentReviewScreen.bankPickerButton.tap()
        XCTAssertTrue(bankSelectionBottomSheet.waitForProviders(),
                      "Bank Selection sheet did not render any provider cells after 30 s.")
        let bankCell = bankSelectionBottomSheet.firstUnselectedBankCell
        XCTAssertTrue(bankCell.waitForExistence(timeout: 10),
                      "No unselected bank cell available — the sheet reported every provider as already selected.")
        let bankID = bankCell.identifier
        bankCell.tap()
        XCTAssertTrue(bankCell.waitForNonExistence(timeout: 10),
                      "Bank Selection sheet did not dismiss after tapping a bank cell.")
        XCTAssertTrue(paymentReviewScreen.payButton.waitForExistence(timeout: 10),
                      "Pay button not reachable after returning from Bank Selection sheet.")
        paymentReviewScreen.bankPickerButton.tap()
        XCTAssertTrue(bankSelectionBottomSheet.waitForProviders(),
                      "Bank Selection sheet did not reopen for selection verification.")
        let reopened = app.cells[bankID]
        XCTAssertTrue(reopened.waitForExistence(timeout: 10),
                      "Previously picked bank \(bankID) is missing from the reopened sheet.")
        XCTAssertTrue(reopened.isSelected,
                      "Previously picked bank \(bankID) is not marked selected after reopening — selection may not have propagated to the provider state.")
    }

    /**
     HEAL-290 — Bank Selection sheet carries the inline **More Information**
     link at the bottom; tapping it presents the Payment Info screen.

     Verifies the sheet's nav-bar title ("More information" /
     "Mehr Informationen") rendered by `PaymentInfoViewController` wrapped
     in its hosting `UINavigationController`.
     */
    func testBankSelectionSheetMoreInformationOpensPaymentFeature() throws {
        openPaymentInfoFromBankSelection()
        XCTAssertTrue(paymentInfoScreen.navBarTitle.waitForExistence(timeout: 10),
                      "Payment Info screen did not appear after tapping More Information on the Bank Selection sheet.")
    }

    // MARK: - Payment Info navigation helper

    /**
     Shared entry: reach Payment Review, open the Bank Selection sheet via
     the bank picker, scroll if needed to make the inline More Information
     link visible, and tap it. On return the Payment Info screen is
     presenting (nav title may still be animating in).
     */
    private func openPaymentInfoFromBankSelection() {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(paymentReviewScreen.bankPickerButton.waitForExistence(timeout: 10),
                      "Payment Review bank picker not reachable.")
        paymentReviewScreen.bankPickerButton.tap()
        XCTAssertTrue(bankSelectionBottomSheet.waitForProviders(),
                      "Bank Selection sheet did not open with provider cells within 30 s.")
        let moreInfo = paymentInfoScreen.moreInformationTrigger
        /// The inline More Information link sits at the bottom of the
        /// `BanksBottomView` stack and may be offscreen on compact-height
        /// devices; a few swipe-up attempts bring it into view before we
        /// give up and let the existence check fail with context.
        var attempts = 0
        while !moreInfo.exists && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(moreInfo.waitForExistence(timeout: 5),
                      "More Information link not found on Bank Selection sheet.")
        moreInfo.tap()
    }

    // MARK: - More Info / Payment Info screen (HEAL-291, 292)

    /**
     HEAL-291 — Payment Info screen renders its informational content.

     Reaches the Bank Selection sheet via the Payment Review bank picker,
     taps the inline **More Information** link, and asserts the Payment Info
     screen is presented with both its nav-bar title ("More information" /
     "Mehr Informationen") and the FAQ section title visible.
     The upstream view (`PaymentInfoViewController`) has no Continue button —
     the SDK's "primary action" at this surface is dismissal, covered by
     HEAL-292.
     */
    func testPaymentFeatureScreenRendersCopyAndContinue() throws {
        openPaymentInfoFromBankSelection()
        XCTAssertTrue(paymentInfoScreen.navBarTitle.waitForExistence(timeout: 10),
                      "Payment Info screen nav-bar title not visible.")
        XCTAssertTrue(paymentInfoScreen.faqTitle.waitForExistence(timeout: 10),
                      "Payment Info FAQ title (Frequently Asked Questions / Häufig gestellte Fragen) not visible.")
    }

    /**
     HEAL-292 — Payment Info screen's primary action dismisses the sheet
     and returns to the Bank Selection sheet underneath.

     The upstream `PaymentInfoViewController` has no close button or
     Continue action; it inherits `GiniBottomSheetViewController` and is
     dismissed by the iOS 13+ modal swipe-down gesture. XCUITest cannot
     reliably simulate that drag against the sheet's drag indicator, so
     this test is skipped until a stable programmatic dismiss hook is
     added upstream (e.g. an accessibility-identified Close bar-button in
     the hosting `UINavigationController`).
     */
    func testPaymentFeatureContinueReturnsToPreviousScreen() throws {
        throw XCTSkip("HEAL-292 — PaymentInfoViewController has no Close/Continue control; needs an upstream accessibility-identified dismiss hook before this can be automated.")
    }

    // MARK: - Payment Review Screen (HEAL-294, 295, 296, 297, 298, 299, 300, 301, 306)

    /**
     HEAL-294 — Multi-page PDF import shows pagination dots on the
     Payment Review Screen's document preview.

     Uses `TestFixtures.Files.multiInvoice` (multi-invoice.pdf, staged by
     the BrowserStack script's `uploadMedia` to Custom_Files; locally
     seeded by `copyFixturesToSimulator`).

     **Entry pattern** (reuse from `GiniHealthSmokeJourneysUITests` HEAL-284):
     ```
     mainScreen.startWithGiniCaptureButton.tap()
     mainScreen.handleSystemPermission(answer: true)
     captureImportFlow.skipOnboardingIfPresented()
     captureImportFlow.tapImportThenFiles()
     captureImportFlow.pickPDFFromFilesPicker(fileName: TestFixtures.Files.multiInvoice)
     // No tapProcessOnReview — PDFs skip the Review screen.
     // Wait for Invoices List with Transfer directly, tap it, then
     // drivePaymentFlowThroughBankSelectionToPaymentReview().
     ```
     Then assert pagination-dot indicators are present on the Payment
     Review Screen's document preview.
     */
    func testMultiPageInvoiceShowsPaginationDots() throws {
        throw XCTSkip("HEAL-294 — pending implementation")
    }

    /**
     HEAL-295 — Payment Review Screen's IBAN field accepts user input.

     Reaches Payment Review, waits for the field to carry an extracted value
     (SwiftUI binding race), focuses the field, appends a sentinel, and
     asserts the value changed. Mirrors the HEAL-293 edit smoke pattern:
     appending rather than clearing avoids iOS 15–26 SwiftUI selection
     differences — the smoke suite only verifies the field is editable.
     */
    func testPaymentReviewIBANFieldAcceptsInput() throws {
        assertPaymentReviewFieldAcceptsAppend(field: paymentReviewScreen.ibanField,
                                               sentinel: "00")
    }

    /**
     HEAL-296 — Payment Review Screen's Recipient field accepts user input.
     */
    func testPaymentReviewRecipientFieldAcceptsInput() throws {
        assertPaymentReviewFieldAcceptsAppend(field: paymentReviewScreen.recipientField,
                                               sentinel: " X")
    }

    /**
     HEAL-297 — Payment Review Screen's Amount field accepts decimal input.

     The amount field uses `.keyboardType(.decimalPad)` and a custom
     keyboard accessory (`GiniKeyboardAccessoryInstaller`). Appending a
     digit is sufficient to prove acceptance; the smoke suite does not
     verify numeric formatting (covered in integration tests).
     */
    func testPaymentReviewAmountFieldAcceptsInput() throws {
        assertPaymentReviewFieldAcceptsAppend(field: paymentReviewScreen.amountField,
                                               sentinel: "1")
    }

    /**
     HEAL-298 — Payment Review Screen's Reference field accepts user input.
     */
    func testPaymentReviewReferenceFieldAcceptsInput() throws {
        assertPaymentReviewFieldAcceptsAppend(field: paymentReviewScreen.referenceField,
                                               sentinel: " X")
    }

    /**
     HEAL-299 — Payment Review Screen's bank picker opens the Bank
     Selection sheet. Taps `paymentReview.bankPicker` and asserts a
     `bankSelection.cell.*` row appears, proving the sheet rendered its
     provider list.
     */
    func testPaymentReviewBankPickerOpensBankSelection() throws {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(paymentReviewScreen.bankPickerButton.waitForExistence(timeout: 10),
                      "Payment Review bank picker not reachable after bank selection.")
        paymentReviewScreen.bankPickerButton.tap()
        XCTAssertTrue(bankSelectionBottomSheet.waitForProviders(),
                      "Bank Selection sheet did not open with provider cells within 30 s after tapping the Payment Review bank picker.")
    }

    /**
     HEAL-300 — Payment Review Screen validates required fields before
     enabling the Pay button; empty IBAN or amount keeps Pay disabled.
     */
    func testPaymentReviewRequiredFieldValidation() throws {
        throw XCTSkip("HEAL-300 — pending implementation (needs clear-field helper tolerant of SwiftUI 15–26 selection differences)")
    }

    /**
     HEAL-301 — Payment Review Screen's close button dismisses the sheet
     and returns to the previous surface (Invoices List).
     */
    func testPaymentReviewCloseDismissesSheet() throws {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear.")
        XCTAssertTrue(paymentReviewScreen.closeButton.waitForExistence(timeout: 10),
                      "Close button not found on Payment Review Screen.")
        paymentReviewScreen.closeButton.tap()
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForNonExistence(timeout: 10),
                      "Payment Review Screen did not dismiss after tapping Close.")
    }

    /**
     HEAL-306 — Payment Review Screen displays the extraction info banner
     ("Please check the pre-filled data.") when fields were populated by
     the extraction pipeline.

     The banner has a ~3 s auto-dismiss timer that starts the instant the
     Payment Review Screen appears (`popupAnimationDuration` default is 3.0
     in `PaymentReviewConfiguration`), so observe it immediately with tight
     polling rather than waiting for the IBAN field first — a slow
     BrowserStack device can hit the IBAN check *after* the banner has
     already auto-dismissed.
     */
    func testPaymentReviewShowsPrefilledDataBanner() throws {
        reachPaymentReviewFromInvoicesList()
        let banner = paymentReviewScreen.prefilledBanner
        let deadline = Date().addingTimeInterval(15)
        while Date() < deadline, !banner.exists {
            Thread.sleep(forTimeInterval: 0.1)
        }
        XCTAssertTrue(banner.exists,
                      "Prefilled-data banner not observed on Payment Review Screen within its ~3 s display window.")
    }

    // MARK: - Field-edit shared helper

    /**
     Reaches Payment Review, polls the field until it carries a non-empty
     extracted value (SwiftUI binding race, same shape as
     `assertPaymentReviewReachedWithPopulatedFields`), focuses the field,
     appends `sentinel`, and asserts the value grew by at least
     `sentinel.count` characters. Mirrors HEAL-293's edit smoke pattern.

     Baseline is captured **after** focus-formatting settles: the Amount
     field strips its currency symbol on focus
     (`handleAmountFocusChange` in `PaymentReviewPaymentInformationObservableModel`),
     so a baseline taken before focus would differ from the post-focus
     value even if typing was dropped — a bare `assertNotEqual` would
     false-pass. Growth-by-length is also robust against the IBAN sentinel
     ("00") already occurring in the extracted baseline (so a `.contains`
     check wouldn't catch dropped typing either).
     */
    private func assertPaymentReviewFieldAcceptsAppend(field: XCUIElement, sentinel: String) {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(field.waitForExistence(timeout: 30),
                      "Payment Review field \(field.identifier) not reachable.")
        let settleDeadline = Date().addingTimeInterval(15)
        while Date() < settleDeadline, paymentReviewScreen.value(of: field).isEmpty {
            Thread.sleep(forTimeInterval: 0.3)
        }
        XCTAssertFalse(paymentReviewScreen.value(of: field).isEmpty,
                       "Payment Review field \(field.identifier) still empty 15 s after screen appeared — extraction model may not have arrived.")
        field.tap()
        var baseline = paymentReviewScreen.value(of: field)
        let focusDeadline = Date().addingTimeInterval(2)
        while Date() < focusDeadline {
            Thread.sleep(forTimeInterval: 0.2)
            let next = paymentReviewScreen.value(of: field)
            if next == baseline { break }
            baseline = next
        }
        field.typeText(sentinel)
        let expectedMinLength = baseline.count + sentinel.count
        let typedDeadline = Date().addingTimeInterval(5)
        var observedValue = baseline
        while Date() < typedDeadline {
            observedValue = paymentReviewScreen.value(of: field)
            if observedValue.count >= expectedMinLength { break }
            Thread.sleep(forTimeInterval: 0.2)
        }
        XCTAssertTrue(observedValue.count >= expectedMinLength,
                      "Payment Review field \(field.identifier) did not accept typed input — value is '\(observedValue)' (length \(observedValue.count)) after typing '\(sentinel)' into baseline '\(baseline)' (expected length ≥ \(expectedMinLength)).")
    }

    // MARK: - Install App bottom sheet (HEAL-303)

    /**
     HEAL-303 — Install App bottom sheet appears when the selected bank's
     app is not installed and the user taps the Pay button. Verifies the
     sheet's title, note, and Forward/Weiter button are present.

     Device-only on BrowserStack (host app is sandboxed, bank apps are
     never installed, so the sheet always appears).

     **Detection pattern** (same as HEAL-304 journey test): no "Install App"
     literal exists on the sheet and no accessibility identifier is set
     upstream, so match on stable localised phrases from
     `InstallAppBottomView`'s strings. Reuse the predicate shape:
     ```swift
     let forwardButton = app.buttons
         .matching(NSPredicate(format: "label IN %@", ["Forward", "Weiter"]))
         .firstMatch
     let installPhraseAny = app.descendants(matching: .any)
         .matching(NSPredicate(format:
             "label CONTAINS[c] 'install' OR label CONTAINS[c] 'App Store' OR label CONTAINS[c] 'App-Store'"))
         .firstMatch
     ```
     */
    func testInstallAppBottomSheetAppearsWhenBankMissing() throws {
        throw XCTSkip("HEAL-303 — pending implementation")
    }

    // MARK: - Open With / Share with (HEAL-305)

    /**
     HEAL-305 — Open With / Share flow surfaces the payment request to
     the system share sheet when the user triggers the handoff via the
     dedicated share entry.
     */
    func testOpenWithShareHandoffShowsShareSheet() throws {
        throw XCTSkip("HEAL-305 — pending implementation")
    }
}
