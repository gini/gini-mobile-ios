//
//  GiniCXOnboardingUITests.swift
//  GiniBankSDKExampleUITests
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Group H — Tests that verify onboarding screen behaviour when `productTag = cxExtractions`.

 These tests navigate only as far as the camera screen and do not require any document file
 to be present on the device, making them safe to run on a simulator as well as on
 BrowserStack.
 */
class GiniCXOnboardingUITests: GiniBankSDKExampleUITests {

    override var additionalLaunchArguments: [String] { ["-ResetCaptureOnboarding"] }

    // MARK: - H1

    func testCXOnboardingSkipButtonIsPresent() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
        //Launch scanning flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        //Assert the onboarding skip button is visible in CX mode
        XCTAssertTrue(onboadingScreen.skipButton.waitForExistence(timeout: 10),
                      "Onboarding skip button should be visible when productTag = cxExtractions.")
        //Clean up — skip onboarding and cancel out
        onboadingScreen.skipOnboardingScreens()
        captureScreen.cancelButtonNavigation.tap()
    }

    // MARK: - H2

    func testCXOnboardingSkipReturnsToCameraScreen() {
        //Select Cross-border product tag
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
        //Launch scanning flow
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Assert the capture screen is shown immediately after skipping onboarding in CX mode
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10),
                      "Camera capture screen should appear after skipping onboarding in CX mode.")
        XCTAssertTrue(captureScreen.captureButton.isHittable,
                      "Capture button should be hittable after skipping onboarding in CX mode.")
        captureScreen.cancelButtonNavigation.tap()
    }

    // MARK: - H3

    func testCXOnboardingAppearsAfterSwitchingFromSEPA() {
        //First: launch capture in SEPA mode (default) and dismiss standard onboarding
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 0)
        //Close settings
        settingScreen.closeButton.tap()
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        //Standard onboarding appears on first launch — dismiss it before reaching camera
        onboadingScreen.skipOnboardingScreens()
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10),
                      "Camera screen should be reachable in SEPA mode.")
        captureScreen.cancelButtonNavigation.tap()

        //Restart the app so -ResetCaptureOnboarding clears onboardingShowed again,
        //ensuring CX onboarding can appear as if it were a fresh launch.
        app.terminate()
        app.launch()

        //Second: switch to Cross-border and verify CX onboarding appears
        mainScreen.configurationButton.tap()
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        //Skip button should be present regardless of whether onboarding was previously shown in SEPA
        onboadingScreen.skipOnboardingScreens()
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10),
                      "Camera capture screen should appear after switching to CX mode and skipping onboarding.")
        captureScreen.cancelButtonNavigation.tap()
    }
}
