//
//  GiniSmokeUITests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Dedicated smoke journeys that have no equivalent in the per-feature suites.

 The smoke run (`Scripts/bs_run_smoke_journeys.sh`) executes this class plus a curated
 method-level selection from the feature suites — together they map the automatable
 part of the smoke test set. Cases requiring the share sheet, network toggling,
 or live camera input stay manual (listed in the script header).
 */
class GiniSmokeUITests: GiniBankSDKExampleUITests {

    /**
     Disables the Return Assistant and Skonto SDK feature flags through the
     settings screen, so a SEPA invoice goes straight to the extraction screen
     instead of detouring through the RA/Skonto feature screens.
     */
    private func disableReturnAssistantAndSkonto() {
        mainScreen.configurationButton.tap()
        settingScreen.setSwitch(nextTo: settingScreen.returnAssistantCellText, enabled: false)
        settingScreen.setSwitch(nextTo: settingScreen.skontoCellText, enabled: false)
        settingScreen.closeButton.tap()
        /// Anchor on the main screen so slow dismiss animations (BrowserStack devices)
        /// cannot race the next step.
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Main screen did not reappear after closing the settings screen.")
    }

    /**
     Uploading a valid SEPA invoice PDF ends on the extraction screen with the
     key payment fields filled.

     RA and Skonto are disabled first: with them on, the invoice can route into
     the Return Assistant or Skonto screens instead of the plain extraction screen.
     */
    func testUploadPDFSEPAInvoiceShowsExtractions() {
        // Route the invoice directly to the extraction screen
        disableReturnAssistantAndSkonto()
        // Start the photo payment flow and upload the SEPA invoice PDF
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.sepaInvoice)
        // Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        // Assert the extraction screen is displayed with the IBAN filled in
        transactionSummaryScreen.assertExtractionsAreDisplayed()
        XCTAssertFalse(transactionSummaryScreen.extractionValue(named: "iban").isEmpty,
                       "Expected the IBAN extraction to be filled in for a valid SEPA invoice.")
        // Close the SDK and assert the host app is back
        transactionSummaryScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10))
    }

    /**
     Uploading a valid SEPA invoice picture from the gallery ends on the extraction
     screen with the key payment fields filled.

     RA and Skonto are disabled first: with them on, the invoice can route into
     the Return Assistant or Skonto screens instead of the plain extraction screen.

     Pre-condition: the SEPA invoice PNG must be the most recently added photo.
     */
    func testUploadPictureSEPAInvoiceShowsExtractions() {
        // Route the invoice directly to the extraction screen
        disableReturnAssistantAndSkonto()
        // Start the photo payment flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        // Import the SEPA invoice image from the photo gallery
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()
        // Process the imported image
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton)
        reviewScreen.processButton.tap()
        waitForAnalysisIfNeeded()
        // Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        // Assert the extraction screen is displayed with the IBAN filled in
        transactionSummaryScreen.assertExtractionsAreDisplayed()
        XCTAssertFalse(transactionSummaryScreen.extractionValue(named: "iban").isEmpty,
                       "Expected the IBAN extraction to be filled in for a valid SEPA invoice.")
    }

    /**
     Uploading a PDF that is not an invoice ends on the No-Results screen with the
     "Enter manually" action.
     */
    func testUploadPDFNoResultsScreen() {
        // Start the photo payment flow and upload a non-invoice PDF
        uploadDocumentViaFilesAndAwaitAnalysis(fileName: TestFixtures.Files.noResultsInvoice)
        // Assert the No-Results screen is displayed with the Enter manually action
        XCTAssertTrue(noResultsScreen.waitForExistence(timeout: 30),
                      "No-Results screen should be displayed for a document without extractions.")
        XCTAssertTrue(noResultsScreen.enterManuallyButton.isHittable)
    }
}
