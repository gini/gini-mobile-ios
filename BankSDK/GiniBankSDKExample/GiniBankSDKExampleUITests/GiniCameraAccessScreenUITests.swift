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
        //Tap Give access button
        cameraAccessScreen.giveAccessButton.firstMatch.tap()
        //Assert that Settings is opened
        let settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        // iOS 18 may open "Settings > Apps" list instead of navigating directly to the app page.
        // If the app title isn't immediately visible, find and tap the app row in the list first.
        let appSettingsTitle = settingsApp.staticTexts["GiniBankSDKExample"]
        if !appSettingsTitle.waitForExistence(timeout: 5) {
            let appCell = settingsApp.cells.containing(.staticText, identifier: "GiniBankSDKExample").firstMatch
            if appCell.waitForExistence(timeout: 5) {
                appCell.tap()
            }
        }
        XCTAssertTrue(settingsApp.staticTexts["GiniBankSDKExample"].waitForExistence(timeout: 5))
        //Reset Camera Access
        if #available(iOS 13.4, *) {
            app.resetAuthorizationStatus(for: .camera)
        }
    }
}

