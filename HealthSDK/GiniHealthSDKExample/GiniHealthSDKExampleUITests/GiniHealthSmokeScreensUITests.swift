//
//  GiniHealthSmokeScreensUITests.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Per-screen UI smoke tests complementing the end-to-end journeys in
 `GiniHealthSmokeJourneysUITests`. Runs on BrowserStack via
 `bs_run_smoke_screens.sh`.

 ## Scope
 - Bank Selection sheet, More Info / Payment Info screens
 - Payment Review Screen (fields, bank picker, close, prefilled banner)
 - Install App bottom sheet, Share-with QR sheet

 ## Explicitly manual (not here)
 - Live camera QR scan — camera-only entry
 - No-network default error — BrowserStack blocks WiFi toggling

 ## Lessons reused from the journey suite
 - **Payment Review entry:** use the shared
   `drivePaymentFlowThroughBankSelectionToPaymentReview` helper. It races
   `paymentComponent.selectBank` against `paymentReview.iban` and handles
   both the first-time Payment Component path and the direct-to-Payment-Review
   path (previously selected bank persists across launches in
   `singleRunnerInvocation` runs).
 - **Field reads:** poll — don't read once. SwiftUI `TextField`s render
   immediately with their `viewModel.*InputState.text` bindings still empty;
   `assertPaymentReviewReachedWithPopulatedFields` polls each field up to 15s.
 - **PDF import skips the Review screen.** `GiniScreenAPICoordinator.initialViewControllers`
   routes `.image` to Review and anything else straight to Analysis — the
   PDF path never shows the Process button.
 - **Files picker:** `pickPDFFromFilesPicker` is adaptive — BS `Custom_Files`
   vs local `On My iPhone → GiniHealthSDKExample` — and taps the nav-bar
   `Open` / `Öffnen` after the file label is selected. Tapping the label
   alone only selects (blue checkmark); it never confirms.
 - **System permissions:** `handleSystemPermission` queries both SpringBoard
   AND the host app. iOS 17+ `PHPickerViewController` limited-access consent
   is presented in-process.
 - **Install App bottom sheet:** `InstallAppBottomView` has no literal
   "Install App" text and no accessibility identifier. Match on stable
   localised phrases — `Forward` / `Weiter` button, OR element containing
   `install` / `installieren` / `App Store` / `App-Store`.
 */
final class GiniHealthSmokeScreensUITests: GiniHealthSDKExampleUITests {

    // MARK: - Bank Selection sheet

    /**
     Bank Selection sheet renders the configured provider list.

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
     Picking a bank from the Bank Selection sheet dismisses the
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
     Bank Selection sheet carries the inline **More Information**
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

    // MARK: - More Info / Payment Info screen

    /**
     Payment Info screen renders its informational content.

     Reaches the Bank Selection sheet via the Payment Review bank picker,
     taps the inline **More Information** link, and asserts the Payment Info
     screen is presented with both its nav-bar title ("More information" /
     "Mehr Informationen") and the FAQ section title visible. The screen
     has no Continue button — dismissal is covered by the swipe-down test.
     */
    func testPaymentFeatureScreenRendersCopyAndContinue() throws {
        openPaymentInfoFromBankSelection()
        XCTAssertTrue(paymentInfoScreen.navBarTitle.waitForExistence(timeout: 10),
                      "Payment Info screen nav-bar title not visible.")
        XCTAssertTrue(paymentInfoScreen.faqTitle.waitForExistence(timeout: 10),
                      "Payment Info FAQ title (Frequently Asked Questions / Häufig gestellte Fragen) not visible.")
    }

    /**
     Payment Info sheet dismiss returns to the Bank Selection sheet underneath.
     `PaymentInfoViewController` has no Close control — dismissal is the iOS 15+
     `UISheetPresentationController` swipe-down, driven here via a coordinate
     drag from the grabber band past the window's bottom edge.
     */
    func testPaymentFeatureContinueReturnsToPreviousScreen() throws {
        openPaymentInfoFromBankSelection()
        XCTAssertTrue(paymentInfoScreen.navBarTitle.waitForExistence(timeout: 10),
                      "Payment Info screen did not open — swipe-down dismiss cannot be exercised.")

        /// `swipeDown()` on the sheet root is unreliable — the inner
        /// `ScrollView` absorbs short drags for its own offset. A long
        /// coordinate drag past the window's bottom edge is the proven
        /// path: iOS routes it to the frontmost presentable sheet
        /// regardless of where the touch starts.
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95))
        start.press(forDuration: 0.1, thenDragTo: end)

        XCTAssertTrue(paymentInfoScreen.navBarTitle.waitForNonExistence(timeout: 10),
                      "Payment Info screen did not dismiss after swipe-down — grabber band may have shifted or the drag was absorbed by inner scroll.")
        XCTAssertTrue(bankSelectionBottomSheet.anyBankCell.waitForExistence(timeout: 10),
                      "Bank Selection sheet underneath not restored after Payment Info dismiss.")
    }

    // MARK: - Payment Review Screen

    /**
     Multi-page PDF import renders pagination dots on the Payment Review
     document preview. `TestFixtures.Files.multiPage` yields N > 1 preview
     images; the SwiftUI `PageTabViewStyle` in `GiniCarouselView` surfaces as
     `XCUIElementType.pageIndicator` with an a11y value of "page X of Y".
     */
    func testMultiPageInvoiceShowsPaginationDots() throws {
        XCTAssertTrue(mainScreen.startWithGiniCaptureButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.startWithGiniCaptureButton.tap()
        mainScreen.handleSystemPermission(answer: true)

        captureImportFlow.skipOnboardingIfPresented()
        captureImportFlow.tapImportThenFiles()
        captureImportFlow.pickPDFFromFilesPicker(fileName: TestFixtures.Files.multiPage)

        /// PDFs skip the Review screen — `GiniScreenAPICoordinator` routes
        /// non-image payloads straight to Analysis, so wait for the Invoices
        /// List without tapping Process.
        XCTAssertTrue(invoicesListScreen.transferDirectlyButton.waitForExistence(timeout: 60),
                      "Invoices List did not appear with the imported multi-page PDF.")
        invoicesListScreen.transferDirectlyButton.tap()

        drivePaymentFlowThroughBankSelectionToPaymentReview()
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear for the multi-page PDF.")

        let pageIndicator = app.pageIndicators.firstMatch
        XCTAssertTrue(pageIndicator.waitForExistence(timeout: 10),
                      "No pagination indicator rendered on Payment Review Screen for multi-page PDF.")

        /// `waitForExistence` returns as soon as the indicator enters the
        /// a11y tree, but SwiftUI's `accessibilityValue` ("page X of Y" EN /
        /// "Seite X von Y" DE) can lag by hundreds of ms. Poll the value
        /// until the parsed count is > 1, so a slow BrowserStack device
        /// doesn't false-fail reading an empty string.
        let deadline = Date().addingTimeInterval(10)
        var rawValue = ""
        var pageCount = 0
        while Date() < deadline {
            rawValue = (pageIndicator.value as? String) ?? ""
            pageCount = Self.pageCount(fromIndicatorValue: rawValue)
            if pageCount > 1 { break }
            Thread.sleep(forTimeInterval: 0.3)
        }
        XCTAssertGreaterThan(pageCount, 1,
                             "Pagination indicator reports \(pageCount) page(s) for multi-page PDF; expected ≥ 2. Raw value: '\(rawValue)'.")
    }

    /**
     Parses the total page count from an `XCUIElement.pageIndicator` a11y
     value such as "page 1 of 3" (EN) or "Seite 1 von 3" (DE). Splits on
     non-numeric characters and returns the trailing number — the total.
     Returns `0` when no digits are present so callers can treat a lagging
     a11y update as "not yet ready".
     */
    private static func pageCount(fromIndicatorValue value: String) -> Int {
        let digits = value.split(whereSeparator: { !$0.isNumber })
        return digits.last.flatMap { Int($0) } ?? 0
    }

    /**
     Payment Review Screen's IBAN field accepts user input.

     Reaches Payment Review, waits for the field to carry an extracted value
     (SwiftUI binding race), focuses the field, appends a sentinel, and
     asserts the value changed. Mirrors the field-edit smoke pattern:
     appending rather than clearing avoids iOS 15–26 SwiftUI selection
     differences — the smoke suite only verifies the field is editable.
     */
    func testPaymentReviewIBANFieldAcceptsInput() throws {
        assertPaymentReviewFieldAcceptsAppend(field: paymentReviewScreen.ibanField,
                                               sentinel: "00")
    }

    /**
     Payment Review Screen's Recipient field accepts user input.
     */
    func testPaymentReviewRecipientFieldAcceptsInput() throws {
        assertPaymentReviewFieldAcceptsAppend(field: paymentReviewScreen.recipientField,
                                               sentinel: " X")
    }

    /**
     Payment Review Screen's Amount field accepts decimal input.

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
     Payment Review Screen's Reference field accepts user input.
     */
    func testPaymentReviewReferenceFieldAcceptsInput() throws {
        assertPaymentReviewFieldAcceptsAppend(field: paymentReviewScreen.referenceField,
                                               sentinel: " X")
    }

    /**
     Payment Review Screen's bank picker opens the Bank
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
     Clearing IBAN and tapping Pay blocks the handoff — no Install App sheet
     and no Share-QR sheet appear. `ibanField.exists` alone is not enough:
     both overlay Payment Review without dismissing it, so a silent regression
     where the SDK ignores empty-field validation would still leave the sheet
     visible. Asserting no handoff signal fires catches that case.
     */
    func testPaymentReviewRequiredFieldValidation() throws {
        reachPaymentReviewFromInvoicesList()
        assertPaymentReviewReachedWithPopulatedFields()

        paymentReviewScreen.ibanField.clearText()
        XCTAssertEqual(paymentReviewScreen.value(of: paymentReviewScreen.ibanField), "",
                       "IBAN not cleared — cannot validate error path.")

        paymentReviewScreen.payButton.tap()

        /// Any handoff signal within 3 s means validation did NOT block the
        /// invalid Pay tap. Install App sheet uses the HEAL-304 predicate
        /// shape; Share-QR sheet uses its localised title fragment.
        let installPhrase = app.descendants(matching: .any)
            .matching(NSPredicate(format:
                "label CONTAINS[c] 'install' OR label CONTAINS[c] 'App Store' OR label CONTAINS[c] 'App-Store'"))
            .firstMatch
        let forwardButton = app.buttons
            .matching(NSPredicate(format: "label IN %@", ["Forward", "Weiter"]))
            .firstMatch
        let shareSheetTitle = app.staticTexts
            .matching(NSPredicate(format:
                "label CONTAINS[c] 'QR payment code' OR label CONTAINS[c] 'QR-Zahlungscode'"))
            .firstMatch

        let deadline = Date().addingTimeInterval(3)
        var handoffDetected = false
        while Date() < deadline {
            if installPhrase.exists || forwardButton.exists || shareSheetTitle.exists {
                handoffDetected = true
                break
            }
            Thread.sleep(forTimeInterval: 0.3)
        }
        XCTAssertFalse(handoffDetected,
                       "A handoff sheet (Install App or Share-QR) appeared after Pay with empty IBAN — validation did not block.")

        XCTAssertTrue(paymentReviewScreen.ibanField.exists,
                      "Payment Review Screen dismissed on Pay with empty IBAN — handoff was not blocked.")
        XCTAssertEqual(paymentReviewScreen.value(of: paymentReviewScreen.ibanField), "",
                       "IBAN field re-populated by SDK after Pay — field should remain empty.")
    }

    /**
     Payment Review Screen's close button dismisses the sheet
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
     Payment Review Screen displays the extraction info banner
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
     `sentinel.count` characters. Mirrors the field-edit smoke pattern.

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

    // MARK: - Install App bottom sheet

    /**
     Install App bottom sheet appears when the user taps Pay with a bank
     whose app is not installed. Reliable on simulator (no bank apps) and
     BrowserStack (sandboxed, no banking apps pre-installed). Matches
     `InstallAppBottomView` by its localised `Forward` / `Weiter` button or
     install / App Store phrase — no accessibility identifier upstream.
     */
    func testInstallAppBottomSheetAppearsWhenBankMissing() throws {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(paymentReviewScreen.payButton.waitForExistence(timeout: 30),
                      "Pay button not reachable — Payment Review Screen may not have loaded.")

        paymentReviewScreen.payButton.tap()

        let forwardButton = app.buttons
            .matching(NSPredicate(format: "label IN %@", ["Forward", "Weiter"]))
            .firstMatch
        let installPhraseAny = app.descendants(matching: .any)
            .matching(NSPredicate(format:
                "label CONTAINS[c] 'install' OR label CONTAINS[c] 'App Store' OR label CONTAINS[c] 'App-Store'"))
            .firstMatch

        let deadline = Date().addingTimeInterval(10)
        var sheetDetected = false
        while Date() < deadline {
            if forwardButton.exists || installPhraseAny.exists {
                sheetDetected = true
                break
            }
            Thread.sleep(forTimeInterval: 0.3)
        }
        XCTAssertTrue(sheetDetected,
                      "Install App bottom sheet did not appear within 10 s after tapping Pay — expected Forward/Weiter button or install/App Store phrase.")
    }

    // MARK: - Open With / Share with

    /**
     Share-with flow surfaces the QR payment-code bottom sheet when the user
     taps Pay after selecting a share-only bank. Picks `Gini Bank SDK Example`
     from the Bank Selection sheet — this provider routes to
     `ShareInvoiceBottomView` instead of a deeplink or Install App fallback.
     Detects the sheet by its localised title ("Share this QR payment code" /
     "QR-Zahlungscode") — `ShareInvoiceBottomView` has no accessibility
     identifier upstream, same approach as the Install App sheet detection.
     */
    func testOpenWithShareHandoffShowsShareSheet() throws {
        reachPaymentReviewFromInvoicesList()
        XCTAssertTrue(paymentReviewScreen.bankPickerButton.waitForExistence(timeout: 10),
                      "Payment Review bank picker not reachable — cannot re-select share-only bank.")
        paymentReviewScreen.bankPickerButton.tap()
        XCTAssertTrue(bankSelectionBottomSheet.waitForProviders(),
                      "Bank Selection sheet did not open with provider cells within 30 s.")

        let shareBankCell = bankSelectionBottomSheet.cell(for: "Gini Bank SDK Example")
        /// Compact-height devices or lineups where installed banks sort
        /// above can push the target row offscreen — scroll a few times
        /// before giving up (same pattern as `openPaymentInfoFromBankSelection`).
        var attempts = 0
        while !shareBankCell.exists && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(shareBankCell.waitForExistence(timeout: 10),
                      "Expected 'Gini Bank SDK Example' provider cell in Bank Selection — share-with flow cannot be exercised without it.")
        shareBankCell.tap()

        XCTAssertTrue(paymentReviewScreen.payButton.waitForExistence(timeout: 10),
                      "Pay button not reachable after selecting Gini Bank SDK Example.")
        paymentReviewScreen.payButton.tap()

        /// Match the sheet by its unique title fragment — "QR" works for EN
        /// ("Share this QR payment code") and both DE variants ("QR-Zahlungscode").
        /// No upstream accessibility identifier on `ShareInvoiceBottomView`.
        let shareSheetTitle = app.staticTexts
            .matching(NSPredicate(format:
                "label CONTAINS[c] 'QR payment code' OR label CONTAINS[c] 'QR-Zahlungscode'"))
            .firstMatch

        let deadline = Date().addingTimeInterval(10)
        var sheetDetected = false
        while Date() < deadline {
            if shareSheetTitle.exists {
                sheetDetected = true
                break
            }
            Thread.sleep(forTimeInterval: 0.3)
        }
        XCTAssertTrue(sheetDetected,
                      "Share-QR bottom sheet did not appear within 10 s after tapping Pay with Gini Bank SDK Example — expected sheet title containing 'QR payment code' or 'QR-Zahlungscode'.")
    }
}
