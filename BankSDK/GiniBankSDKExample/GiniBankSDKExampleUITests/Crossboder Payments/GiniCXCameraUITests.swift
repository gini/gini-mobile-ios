//
//  GiniCXCameraUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
Tests that verify the camera hint label changes based on the active product tag.

 Localisation key reference:
 - `"ginicapture.camera.infoLabel.invoice.and.qr"` → "Scan invoice or QR code" (SEPA, QR enabled)
 - `"ginicapture.camera.infoLabel.only.invoice"` → "Scan invoice"              (CX, QR disabled | SEPA, QR disabled)
 */
class GiniCXCameraUITests: GiniBankSDKExampleUITests {


    func testCXCameraLabelShowsScanInvoiceOnly() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Select Cross-border (index 1) — disables QR scanning automatically
        settingScreen.selectProductTag(index: 1)
        //Close settings
        settingScreen.closeButton.tap()
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

    func testSEPACameraLabelShowsScanInvoiceOrQRCode() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Ensure SEPA is selected (index 0 — default, QR scanning enabled)
        settingScreen.selectProductTag(index: 0)
        //Close settings
        settingScreen.closeButton.tap()
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

    func testSEPACameraLabelShowsScanInvoiceWhenQRDisabled() {
        //Tap Configuration button
        mainScreen.configurationButton.tap()
        //Scroll to Product Tag segmented control
        mainScreen.swipeToElement(element: settingScreen.productTagSegmentedControl, direction: "up")
        //Ensure SEPA is selected (index 0 — default)
        settingScreen.selectProductTag(index: 0)
        //If QR switch is not yet visible on screen, scroll until it is
        if !settingScreen.qrCodeScanSwitch.isHittable {
            mainScreen.swipeToElement(element: settingScreen.qrCodeScanSwitch, direction: "up")
        }
        //Disable QR code scanning if it is currently enabled
        settingScreen.disableSwitchIfOn(settingScreen.qrCodeScanSwitch)
        //Close settings
        settingScreen.closeButton.tap()
        //Tap Photo Payment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Assert camera hint shows invoice-only label (QR manually disabled on SEPA)
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
        captureScreen.assertCameraInfoLabel(expectedText: "Scan invoice")
        //Tap Cancel to exit
        captureScreen.cancelButtonNavigation.tap()
    }
}
