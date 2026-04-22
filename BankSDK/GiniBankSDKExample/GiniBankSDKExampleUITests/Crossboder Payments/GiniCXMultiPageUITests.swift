//
//  GiniCXMultiPageUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// To launch these tests and closely mimic real user behaviour:
// 1. Set "Credentials Set" to "Cross border client" in Settings.
// 2. Enable "Multipage" in Feature Toggles within Settings.
// 3. Upload to device:
//    "cx_invoice_multi_page"       — CX multi page invoice (PDF test)
//    "multi_page_invoice_CX_page1" — first page PNG for the two-file PNG upload test
//    "multi_page_invoice_CX_page2" — second page PNG for the two-file PNG upload test

/**
 Smoke tests that verify multi-page CX invoice import and processing
 without a crash when `productTag = cxExtractions` and multipage is enabled.
 */
class GiniCXMultiPageUITests: GiniBankSDKExampleUITests {

    /*
     To launch this test and closely mimic real user behaviour
     Please upload to device:
         "cx_invoice_multi_page" -  CX multi page invoice (PDF test)
         "multi_page_invoice_CX_page1" — first page of a multi-page CX invoice
         "multi_page_invoice_CX_page2" — second page of the same CX invoice
     */

    func testCXMultiPageInvoiceFlow() {
        //Enable Multipage in Settings
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag and select Cross-border
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
        //Tap Photo Payment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Upload first page
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.cxMultiPageInvoicePDF)
        //Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
        //Assert either Transfer Summary or No-Results screen is shown (no crash expected)
        let transferSummaryAppeared = transactionSummaryScreen.doneButton.waitForExistence(timeout: 15)
        let noResultsAppeared = noResultsScreen.waitForExistence(timeout: 5)
        XCTAssertTrue(transferSummaryAppeared || noResultsAppeared,
                      "Either Transfer Summary or No-Results screen should appear after multi-page CX analysis.")
        //Close SDK gracefully
        if transferSummaryAppeared {
            transactionSummaryScreen.tapDoneButton()
        } else {
            noResultsScreen.backToCameraButton.tap()
        }
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10))
    }

    func testCXMultiPageInvoiceFlowTwoSeparatePNGPages() {
        //Open Settings: select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Enable the multipage switch — scroll to it first if it is not yet on screen
        if !settingScreen.multiPageSwitch.isHittable {
            mainScreen.swipeToElement(element: settingScreen.multiPageSwitch, direction: "up")
        }
        mainScreen.handleConfigurationSetting(element: settingScreen.multiPageSwitch, enabled: true)
        //Close settings
        settingScreen.closeButton.tap()
        //Launch photo payment flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        //Upload page 2 from gallery (multi_page_invoice_CX_page2.png is uploaded last in the script — most recent)
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()
        //Tap "Add pages" on the Review screen to return to capture and upload the first page
        XCTAssertTrue(reviewScreen.addPageButton.waitForExistence(timeout: 10),
                      "Add pages button should be visible on the Review screen when multipage is enabled")
        reviewScreen.addPageButton.tap()
        //Upload page 1 from gallery (multi_page_invoice_CX_page1.png is uploaded first — second-to-last photo)
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        uploadLatestPhotoFromGallery(offset: 1)
        //Process both pages
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear after uploading both pages")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
        //Transaction docs may appear — dismiss if present
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }

        //Assert either Transfer Summary or No-Results screen appears (no crash expected)
        let transferSummaryAppeared = transactionSummaryScreen.doneButton.waitForExistence(timeout: 15)
        let noResultsAppeared = noResultsScreen.waitForExistence(timeout: 5)
        XCTAssertTrue(transferSummaryAppeared || noResultsAppeared,
                      "Either Transfer Summary or No-Results screen should appear after two-page CX analysis.")
        //Close SDK gracefully
        if transferSummaryAppeared {
            transactionSummaryScreen.tapDoneButton()
        } else {
            noResultsScreen.backToCameraButton.tap()
        }
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10),
                      "Should return to main screen after completing the two-page CX flow.")
    }
}

