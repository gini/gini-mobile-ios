//
//  GiniCameraAccessScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest


class GiniCameraAccessScreenUITests: GiniBankSDKExampleUITests {

    func testCameraAccessScreenBackButton() throws {
        
        //Reset Camera Access
        app.terminate()
        app.resetAuthorizationStatus(for: .camera)
        app.launch()
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: false)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Cancel button
        cameraAccessScreen.cancelButtonNavigation.tap()
        //Assert that Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
        //Reset Camera Access
        app.resetAuthorizationStatus(for: .camera)
    }
    
    func testCameraAccessScreenHelpButton() throws {
        
        //Reset Camera Access
        app.terminate()
        app.resetAuthorizationStatus(for: .camera)
        app.launch()
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: false)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Help button
        cameraAccessScreen.helpButton.tap()
        //Assert that Help screen is displayed
        XCTAssertTrue(helpScreen.cameraBackButton.isHittable)
        //Reset Camera Access
        app.resetAuthorizationStatus(for: .camera)
    }
    
    func testCameraAccessScreenGiveAccessButton() throws {
        
        //Reset Camera Access
        app.terminate()
        app.resetAuthorizationStatus(for: .camera)
        app.launch()
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: false)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Give access button
        cameraAccessScreen.giveAccessButton.firstMatch.tap()
        //Assert that Settings is opened (foreground) — avoid depending on Settings' internal layout,
        //which varies between iOS versions.
        let settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        XCTAssertTrue(settingsApp.wait(for: .runningForeground, timeout: 5),
                      "Settings.app did not open after tapping Give access")
        //Reset Camera Access
        app.resetAuthorizationStatus(for: .camera)
    }
}

