//
//  GiniCXNoResultsUITests.swift
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
// 2. Upload to device: "cx_no_results_invoice" — a document that produces no CX extractions
//    (e.g. a blank page or an image irrelevant to cross-border payments).

/**
 Group E — Tests that verify the No-Results screen is shown when CX analysis returns
 no `compoundExtractions.crossBorderPayment` data.
 */
class GiniCXNoResultsUITests: GiniBankSDKExampleUITests {

    /*
     To launch these tests and closely mimic real user behaviour
     Please upload to device:
         "cx_no_results_invoice" — a document the CX backend cannot extract payments from
     */
    let noResultsFileName = "cx_no_results_invoice"

    // MARK: - E1

    func testCXNoResultsScreenIsDisplayedWhenNoExtractions() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Launch scanning flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileWithName(fileName: noResultsFileName)
        captureScreen.openGalleryButton.tap()
        //Assert the No-Results screen (retry button) appears instead of Transfer Summary
        XCTAssertTrue(noResultsScreen.waitForExistence(timeout: 30),
                      "No-Results screen should be displayed when CX backend returns no extractions.")
        //Assert Transfer Summary Done button is NOT shown
        XCTAssertFalse(transactionSummaryScreen.doneButton.exists,
                       "Transfer Summary should not appear when there are no CX extractions.")
    }

    // MARK: - E2

    func testCXNoResultsScreenRetryAction() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Launch scanning flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileWithName(fileName: noResultsFileName)
        captureScreen.openGalleryButton.tap()
        //Wait for No-Results screen
        XCTAssertTrue(noResultsScreen.waitForExistence(timeout: 30))
        //Tap Back to camera button
        noResultsScreen.backToCameraButton.tap()
        //Assert camera capture screen is shown again
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }
}
