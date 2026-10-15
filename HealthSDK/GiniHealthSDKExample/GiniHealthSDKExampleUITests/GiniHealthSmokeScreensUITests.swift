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
 */
final class GiniHealthSmokeScreensUITests: GiniHealthSDKExampleUITests {

    // MARK: - Bank Selection sheet (HEAL-288, 289, 290)

    /**
     HEAL-288 — Bank Selection sheet renders the full configured provider list.

     Steps: open Invoices List → Transfer directly → Payment Component →
     tap Select bank → verify the Bank Selection sheet appears and
     contains at least one `bankSelection.cell.*` row.
     */
    func testBankSelectionSheetShowsProviders() throws {
        throw XCTSkip("HEAL-288 — pending implementation")
    }

    /**
     HEAL-289 — Picking a bank from the Bank Selection sheet dismisses the
     sheet and updates the Payment Component to show the selected bank.
     */
    func testBankSelectionSheetSelectionUpdatesPaymentComponent() throws {
        throw XCTSkip("HEAL-289 — pending implementation")
    }

    /**
     HEAL-290 — Bank Selection sheet carries the "More information" entry
     at the bottom; tapping it opens the Payment Feature screen.
     */
    func testBankSelectionSheetMoreInformationOpensPaymentFeature() throws {
        throw XCTSkip("HEAL-290 — pending implementation")
    }

    // MARK: - More Info / Payment Feature (HEAL-291, 292)

    /**
     HEAL-291 — Payment Feature screen displays the SDK's informational
     copy and the primary Continue action.
     */
    func testPaymentFeatureScreenRendersCopyAndContinue() throws {
        throw XCTSkip("HEAL-291 — pending implementation")
    }

    /**
     HEAL-292 — Payment Feature screen's Continue action dismisses the
     screen and returns the user to the previous surface
     (Bank Selection sheet or Payment Component).
     */
    func testPaymentFeatureContinueReturnsToPreviousScreen() throws {
        throw XCTSkip("HEAL-292 — pending implementation")
    }

    // MARK: - Payment Review Screen (HEAL-294, 295, 296, 297, 298, 299, 300, 301, 306)

    /**
     HEAL-294 — Multi-page PDF import shows pagination dots on the
     Payment Review Screen's document preview.

     Uses `TestFixtures.Files.multiInvoice` (multi-invoice.pdf, staged by
     the BrowserStack script's `uploadMedia` to Custom_Files; locally
     seeded by `copyFixturesToSimulator`).
     */
    func testMultiPageInvoiceShowsPaginationDots() throws {
        throw XCTSkip("HEAL-294 — pending implementation")
    }

    /**
     HEAL-295 — Payment Review Screen's IBAN field accepts user input and
     clears any pre-filled extraction value.
     */
    func testPaymentReviewIBANFieldAcceptsInput() throws {
        throw XCTSkip("HEAL-295 — pending implementation")
    }

    /**
     HEAL-296 — Payment Review Screen's Recipient field accepts user
     input and clears any pre-filled extraction value.
     */
    func testPaymentReviewRecipientFieldAcceptsInput() throws {
        throw XCTSkip("HEAL-296 — pending implementation")
    }

    /**
     HEAL-297 — Payment Review Screen's Amount field accepts decimal
     input via the keyboard accessory Done action.
     */
    func testPaymentReviewAmountFieldAcceptsInput() throws {
        throw XCTSkip("HEAL-297 — pending implementation")
    }

    /**
     HEAL-298 — Payment Review Screen's Reference field accepts user
     input and clears any pre-filled extraction value.
     */
    func testPaymentReviewReferenceFieldAcceptsInput() throws {
        throw XCTSkip("HEAL-298 — pending implementation")
    }

    /**
     HEAL-299 — Payment Review Screen's bank picker opens the Bank
     Selection sheet when tapped.
     */
    func testPaymentReviewBankPickerOpensBankSelection() throws {
        throw XCTSkip("HEAL-299 — pending implementation")
    }

    /**
     HEAL-300 — Payment Review Screen validates required fields before
     enabling the Pay button; empty IBAN or amount keeps Pay disabled.
     */
    func testPaymentReviewRequiredFieldValidation() throws {
        throw XCTSkip("HEAL-300 — pending implementation")
    }

    /**
     HEAL-301 — Payment Review Screen's close button dismisses the sheet
     and returns to the previous surface (Invoices List or host app).
     */
    func testPaymentReviewCloseDismissesSheet() throws {
        throw XCTSkip("HEAL-301 — pending implementation")
    }

    /**
     HEAL-306 — Payment Review Screen displays the extraction info banner
     ("Please check the pre-filled data.") when fields were populated by
     the extraction pipeline.
     */
    func testPaymentReviewShowsPrefilledDataBanner() throws {
        throw XCTSkip("HEAL-306 — pending implementation")
    }

    // MARK: - Install App bottom sheet (HEAL-303)

    /**
     HEAL-303 — Install App bottom sheet appears when the selected bank's
     app is not installed and the user taps the Pay button. Verifies the
     sheet's title, note, and Forward/Weiter button are present.

     Device-only on BrowserStack (host app is sandboxed, bank apps are
     never installed, so the sheet always appears).
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
