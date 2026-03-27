//
//  GiniCXErrorScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// All the test methods have "manual" as a prefix because the tests require a physical device.
// Please remove the prefix if you want to test locally on a simulator.

/**
 Group F — Smoke tests that verify the Error screen behaviour when `productTag = cxExtractions`.

 The error screen is triggered by taking a blank/black photo that cannot be analysed by the backend.
 These tests mirror the existing `GiniErrorScreenUITests`, ensuring the error flow has no regression
 under the CX product tag.
 */
class GiniCXErrorScreenUITests: GiniBankSDKExampleUITests {

    // MARK: - F1

    func testCXErrorScreenBackToCameraButton() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Tap Photo Payment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Take a blank picture to trigger the error screen
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
        captureScreen.captureButton.tap()
        //Wait for Error screen to appear
        XCTAssertTrue(errorScreen.enterManuallyButton.waitForExistence(timeout: 20))
        //Tap "Back to camera" button
        errorScreen.backToCameraButton.tap()
        //Assert camera screen is shown again
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }

    // MARK: - F2

    func testCXErrorScreenEnterManually() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Tap Photo Payment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Take a blank picture to trigger the error screen
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
        captureScreen.captureButton.tap()
        //Wait for Error screen to appear
        XCTAssertTrue(errorScreen.enterManuallyButton.waitForExistence(timeout: 20))
        //Tap "Enter manually" button
        errorScreen.enterManuallyButton.tap()
        //Tap "OK" on the confirmation alert
        errorScreen.okButton.tap()
        //Assert main screen is displayed (SDK closed)
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
}
