//
//  GiniCameraAccessScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class GiniCameraAccessScreenUITests: GiniBankSDKExampleUITests {
    
    /*
     On iOS <13.5 tests works only if app was deleted before launch or camera access was denied
     */
    
    func testCameraAccessScreenBackButton() throws {
        
        //Reset Camera Access
        app.terminate()
        //Don't work on simulators
        if #available(iOS 13.4, *) {
            app.resetAuthorizationStatus(for: .camera)
        }
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
        if #available(iOS 13.4, *) {
            app.resetAuthorizationStatus(for: .camera)
        }
    }
    
    func testCameraAccessScreenHelpButton() throws {
        
        //Reset Camera Access
        app.terminate()
        //Don't work on simulators
        if #available(iOS 13.4, *) {
            app.resetAuthorizationStatus(for: .camera)
        }
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
        if #available(iOS 13.4, *) {
            app.resetAuthorizationStatus(for: .camera)
        }
    }
    
    func testCameraAccessScreenGiveAccessButton() throws {
        
//        //Reset Camera Access
//        app.terminate()
//        //Don't work on simulators
//        if #available(iOS 13.4, *) {
//            app.resetAuthorizationStatus(for: .camera)
//        }
//        app.launch()
//        //Tap Photopaymen button
//        mainScreen.photoPaymentButton.tap()
//        //Handle Camera access pop up
//        mainScreen.handleCameraPermission(answer: false)
//        //Skip onboarding
//        onboadingScreen.skipOnboardingScreens()
//        //Tap Give access button
//        cameraAccessScreen.giveAccessButton.firstMatch.tap()
//        //Assert that Settings is opened
//        let settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
//        XCTAssertTrue(settingsApp.staticTexts["GiniBankSDKExample"].waitForExistence(timeout: 5))
//        //Reset Camera Access
//        if #available(iOS 13.4, *) {
//            app.resetAuthorizationStatus(for: .camera)
//        }
    }
}
