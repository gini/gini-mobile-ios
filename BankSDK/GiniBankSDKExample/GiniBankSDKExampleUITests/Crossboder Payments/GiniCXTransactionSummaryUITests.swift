//
//  GiniCXTransactionSummaryUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// To launch these tests and closely mimic real user behaviour:
// 1. Set "Credentials Set" to "Cross border client" in Settings (for D1–D3).
// 2. Upload to device:
//    "cx_invoice"   — a CX invoice that produces crossBorderPayment extractions
//    "sepa_invoice" — a SEPA invoice for the regression test D4

/**
 Group D — Tests that verify the Transfer Summary screen behaviour for CX and SEPA flows.
 */
class GiniCXTransactionSummaryUITests: GiniBankSDKExampleUITests {

    /*
     To launch these tests and closely mimic real user behaviour
     Please upload to device:
         "cx_invoice"   — CX invoice with crossBorderPayment extractions
         "sepa_invoice" — standard SEPA invoice
     */

    // MARK: - D1

    func testCXTransactionSummaryDisplaysExtractions() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
        //Launch scanning flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
        //Handle Return Assistant if it appears
        if returnAssistantScreen.getStartedButton.waitForExistence(timeout: 15) {
            returnAssistantScreen.getStartedButton.tap()
            returnAssistantScreen.proceedButton.tap()
        }
        //Tap Only for this transaction if the dialog appears
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 15) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        //Assert Transfer Summary appears and shows at least one extraction
        transactionSummaryScreen.assertExtractionsAreDisplayed()
        //Close SDK
        transactionSummaryScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }

    // MARK: - D2

    func testCXTransactionSummaryFieldsAreEditable() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
        //Launch scanning flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
        //Handle Return Assistant if it appears
        if returnAssistantScreen.getStartedButton.waitForExistence(timeout: 15) {
            returnAssistantScreen.getStartedButton.tap()
            returnAssistantScreen.proceedButton.tap()
        }
        //Tap Only for this transaction if the dialog appears
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 15) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        //Assert at least one extraction cell is visible
        XCTAssertTrue(transactionSummaryScreen.firstExtractionCell.waitForExistence(timeout: 20))
        //Assert that the first text field in the extraction cell is editable
        let firstTextField = transactionSummaryScreen.firstExtractionCell.textFields.firstMatch
        XCTAssertTrue(firstTextField.waitForExistence(timeout: 5),
                      "CX extraction fields should be editable text fields.")
        //Close SDK
        transactionSummaryScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }

    // MARK: - D3

    func testCXTransactionSummaryProceedFlow() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
        //Launch scanning flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
        //Handle Return Assistant if it appears
        if returnAssistantScreen.getStartedButton.waitForExistence(timeout: 15) {
            returnAssistantScreen.getStartedButton.tap()
            returnAssistantScreen.proceedButton.tap()
        }
        //Tap Only for this transaction if the dialog appears
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 15) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        //Wait for Transfer Summary
        XCTAssertTrue(transactionSummaryScreen.doneButton.waitForExistence(timeout: 15))
        //Tap Done — submits transfer summary and closes the SDK
        transactionSummaryScreen.tapDoneButton()
        //Assert main screen is shown (SDK closed successfully)
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10))
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }

    // MARK: - D4

    func testSEPATransactionSummaryRegression() {
        //Ensure SEPA product tag is selected (default)
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 0)
        //Close settings
        settingScreen.closeButton.tap()
        //Launch scanning flow with a SEPA invoice
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.cxInvoice)
        captureScreen.openGalleryButton.tap()
        //Handle Return Assistant if it appears (SEPA flow may show it depending on invoice content)
        if returnAssistantScreen.getStartedButton.waitForExistence(timeout: 15) {
            returnAssistantScreen.getStartedButton.tap()
            returnAssistantScreen.proceedButton.tap()
        }
        //Tap Only for this transaction if the dialog appears (may be skipped depending on invoice/device)
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 15) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        //Assert Transfer Summary appears and shows extractions
        transactionSummaryScreen.assertExtractionsAreDisplayed()
        //Tap send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 10))
        mainScreen.sendFeedbackButton.tap()
        //Assert main screen is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }
}
