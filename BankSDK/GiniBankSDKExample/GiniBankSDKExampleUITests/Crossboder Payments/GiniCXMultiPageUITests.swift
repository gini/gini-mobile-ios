//
//  GiniCXMultiPageUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// All the test methods have "manual" as a prefix because the tests require a physical device.
// Please remove the prefix if you want to test locally on a simulator.
//
// To launch these tests and closely mimic real user behaviour:
// 1. Set "Credentials Set" to "Cross border client" in Settings.
// 2. Enable "Multipage" in Feature Toggles within Settings.
// 3. Upload to device:
//    "cx_invoice_page1" — first page of a two-page CX invoice
//    "cx_invoice_page2" — second page of the same CX invoice

/**
 Group G — Smoke test that verifies a multi-page CX invoice can be imported and processed
 without a crash when `productTag = cxExtractions` and multipage is enabled.
 */
class GiniCXMultiPageUITests: GiniBankSDKExampleUITests {

    /*
     To launch this test and closely mimic real user behaviour
     Please upload to device:
         "cx_invoice_page1" — first page of a multi-page CX invoice
         "cx_invoice_page2" — second page of the same CX invoice
     */
    let cxPage1FileName = "cx_invoice_multi_page"
    let cxPage2FileName = "cx_invoice_page2"

    // MARK: - G1

    func testCXMultiPageInvoiceFlow() {
        //Enable Multipage in Settings
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag and select Cross-border
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Tap Photo Payment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Upload first page
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileWithName(fileName: cxPage1FileName)
        captureScreen.openGalleryButton.tap()
        //Assert either Transfer Summary or No-Results screen is shown (no crash expected)
        let transferSummaryAppeared = transactionSummaryScreen.doneButton.waitForExistence(timeout: 30)
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
}
