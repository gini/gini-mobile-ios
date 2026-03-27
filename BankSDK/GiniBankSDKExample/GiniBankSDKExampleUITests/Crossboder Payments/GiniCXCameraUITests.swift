//
//  GiniCXCameraUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// All the test methods have "manual" as a prefix because the tests require a physical device.
// Please remove the prefix if you want to test locally on a simulator.

/**
 Group B — Tests that verify the camera hint label changes based on the active product tag.

 Localisation key reference:
 - `"ginicapture.camera.infoLabel.invoice.and.qr"` → "Scan invoice or QR code" (SEPA, QR enabled)
 - `"ginicapture.camera.infoLabel.only.invoice"` → "Scan invoice"              (CX, QR disabled)
 */
class GiniCXCameraUITests: GiniBankSDKExampleUITests {

    // MARK: - B1

    func testCXCameraLabelShowsScanInvoiceOnly() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Select Cross-border (index 1) — disables QR scanning automatically
        settingScreen.selectProductTag(index: 1)
        //Tap Photo Payment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Assert camera hint shows invoice-only label (QR disabled)
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
        captureScreen.assertCameraInfoLabel(expectedText: "Scan invoice")
        //Tap Cancel to exit
        captureScreen.cancelButtonNavigation.tap()
    }

    // MARK: - B2

    func testSEPACameraLabelShowsScanInvoiceOrQRCode() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Ensure SEPA is selected (index 0 — default, QR scanning enabled)
        settingScreen.selectProductTag(index: 0)
        //Tap Photo Payment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Assert camera hint shows the "invoice or QR code" label
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
        captureScreen.assertCameraInfoLabel(expectedText: "Scan invoice or QR code")
        //Tap Cancel to exit
        captureScreen.cancelButtonNavigation.tap()
    }
}
