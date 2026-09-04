//
//  GiniBankSDKExampleUITests+CreditNote.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Shared journeys and assertions for the Credit Note Warning flag matrix.

 The manual test cases toggle the backend ("frontend") `creditNoteHintEnabled` client
 configuration flag with Charles. On BrowserStack no proxy is available, so these runs
 launch the app with the `-UITestMockScenario` / `-UITestMockClientConfig` arguments:
 the example app then swaps the network layer for `UITestMockBackend`, which serves the
 `creditNote` scenario payload and a client configuration flag controlled per test class.

 No real backend is involved — any PDF fixture works as the uploaded document, so these
 tests reuse the existing `test_image` fixture.

 | Class                                | Frontend flag | SDK flag | Warning |
 |--------------------------------------|---------------|----------|---------|
 | GiniCreditNoteMockBackendFlagOnUITests  | ON            | ON       | shown   |
 | GiniCreditNoteMockBackendFlagOnUITests  | ON            | OFF      | hidden  |
 | GiniCreditNoteMockBackendFlagOffUITests | OFF           | ON       | hidden  |
 | GiniCreditNoteMockBackendFlagOffUITests | OFF           | OFF      | hidden  |
 */
extension GiniBankSDKExampleUITests {

    /**
     Shared journey for the flag matrix: starts the photo payment flow, uploads a PDF
     fixture through the Files picker, and waits for the (mocked) analysis to finish.
     - Parameters:
       - fileName: Fixture name from `TestFixtures.Files`.
     */
    func uploadDocumentViaFilesAndAwaitAnalysis(fileName: String) {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileFromBestAvailableSource(fileName: fileName)
        // Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
        waitForAnalysisIfNeeded()
    }

    /**
     Disables the SDK credit note hint flag through the settings screen.
     */
    func disableCreditNoteSdkFlag() {
        mainScreen.configurationButton.tap()
        settingScreen.setSwitch(nextTo: settingScreen.creditNoteHintCellText, enabled: false)
        settingScreen.closeButton.tap()
        /// Anchor on the main screen so slow dismiss animations (BrowserStack devices)
        /// cannot race the next step.
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Main screen did not reappear after closing the settings screen.")
    }

    /**
     Asserts the warning never gated the flow and the document lands on the Transfer
     Summary screen with a filled amount — processed like a regular invoice.
     Anchors on the summary first, then checks the warning is absent, avoiding a fixed
     dead wait for the negative check.
     */
    func assertProcessedLikeRegularInvoice() {
        // Transaction docs screen is optional — shown when the docs flag is on; skipped otherwise.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        transactionSummaryScreen.assertExtractionsAreDisplayed()
        XCTAssertFalse(creditNoteWarningScreen.title.exists,
                       "Credit Note Warning must not appear for this flag combination.")
        XCTAssertFalse(transactionSummaryScreen.extractionValue(named: "amountToPay").isEmpty,
                       "Expected amountToPay to stay filled when the warning is disabled.")
    }
}
