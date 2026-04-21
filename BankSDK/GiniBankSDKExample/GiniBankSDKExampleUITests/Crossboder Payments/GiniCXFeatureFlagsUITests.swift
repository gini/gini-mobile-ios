//
//  GiniCXFeatureFlagsUITests.swift
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
// 2. Upload cx_invoice.png to the device Photos library (BrowserStack: upload as last media so uploadLatestPhotoFromGallery picks it).

/**
 Group C — Smoke tests that verify Skonto and Return Assistant are suppressed
 when `productTag = cxExtractions`.
 */
class GiniCXFeatureFlagsUITests: GiniBankSDKExampleUITests {

    /*
     To launch these tests and closely mimic real user behaviour
     Please upload to device:
         "cx_invoice" — a CX-compatible test invoice
     */

    // MARK: - C1

    func testCXSkontoScreenIsNotShown() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control and select Cross-border
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
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload photo button
        captureScreen.uploadPhotoButton.tap()
        //Handle photo library permission
        mainScreen.handlePhotoPermission(answer: true)
        //Select the latest photo from gallery (cx_invoice.png uploaded last via BrowserStack)
        uploadLatestPhotoFromGallery()
        //Wait for and tap Process button on review screen
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
        //Assert Skonto "Got it" button does NOT appear — Skonto is disabled for CX
        let skontoGotItButton = skontoScreen.gotItButton
        XCTAssertFalse(skontoGotItButton.waitForExistence(timeout: 15),
                       "Skonto screen should not be shown when productTag = cxExtractions.")
        //Dismiss transaction docs alert
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert the Transfer Summary screen (Done button) does eventually appear
        XCTAssertTrue(transactionSummaryScreen.doneButton.waitForExistence(timeout: 30))
        //Tap Done to close
        transactionSummaryScreen.tapDoneButton()
        //Assert Photo Payment button is displayed (SDK closed)
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }

    // MARK: - C2

    func testCXReturnAssistantScreenIsNotShown() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control and select Cross-border
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
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload photo button
        captureScreen.uploadPhotoButton.tap()
        //Handle photo library permission
        mainScreen.handlePhotoPermission(answer: true)
        //Select the latest photo from gallery (cx_invoice.png uploaded last via BrowserStack)
        uploadLatestPhotoFromGallery()
        //Wait for and tap Process button on review screen
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
        //Assert Return Assistant "Get started" button does NOT appear
        let raGetStartedButton = returnAssistantScreen.getStartedButton
        XCTAssertFalse(raGetStartedButton.waitForExistence(timeout: 15),
                       "Return Assistant screen should not be shown when productTag = cxExtractions.")
        //Dismiss transaction docs alert
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert the Transfer Summary screen (Done button) does eventually appear
        XCTAssertTrue(transactionSummaryScreen.doneButton.waitForExistence(timeout: 30))
        //Tap Done to close
        transactionSummaryScreen.tapDoneButton()
        //Assert Photo Payment button is displayed (SDK closed)
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }
}
