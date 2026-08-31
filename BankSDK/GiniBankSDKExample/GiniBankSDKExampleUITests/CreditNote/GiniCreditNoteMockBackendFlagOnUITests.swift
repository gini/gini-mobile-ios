//
//  GiniCreditNoteMockBackendFlagOnUITests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Credit Note Warning flag matrix — frontend (backend client configuration) flag ON.
 The mock backend serves `creditNoteHintEnabled == true`; see
 `GiniBankSDKExampleUITests+CreditNote.swift` for the full matrix and shared journeys.
 */
class GiniCreditNoteMockBackendFlagOnUITests: GiniBankSDKExampleUITests {

    override var additionalLaunchArguments: [String] {
        ["-UITestMockScenario", "creditNote",
         "-UITestMockClientConfig", "creditNoteHintEnabled=true"]
    }

    /**
     Frontend flag ON + SDK flag ON — the warning is displayed.
     */
    func testWarningShownWhenSdkFlagOn() {
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.creditNote)
        // Assert the warning sheet appeared with both buttons
        XCTAssertTrue(creditNoteWarningScreen.waitForDialog(timeout: 15),
                      "Credit Note Warning must appear when both flags are ON.")
        // Proceed and assert the amount was stripped from the delivered result
        creditNoteWarningScreen.proceedAnywayButton.tap()
        // Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        transactionSummaryScreen.assertExtractionsAreDisplayed()
        XCTAssertTrue(transactionSummaryScreen.extractionValue(named: "amountToPay").isEmpty,
                      "Expected amountToPay to be stripped after proceeding on a credit note.")
    }

    /**
     Frontend flag ON + SDK flag OFF — no warning, processed like an invoice.
     */
    func testWarningNotShownWhenSdkFlagOff() {
        disableCreditNoteSdkFlag()
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.creditNote)
        assertProcessedLikeRegularInvoice()
    }
}
