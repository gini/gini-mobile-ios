//
//  GiniHelpScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

class GiniHelpScreenUITests: GiniBankSDKExampleUITests {
    
    func testHelpScreenTipsButton() {
        
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Help button
        captureScreen.helpButton.tap()
        //Tap Tips button
        helpScreen.tipsForBestResultLabel.tap()
        //Tap back button
        helpScreen.helpBackButton.tap()
        //Assert that Help screen is displayed
        XCTAssertTrue(helpScreen.cameraBackButton.isHittable)
    }
    
    func testHelpScreenSupportedFormatsButton() {
        
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Help button
        captureScreen.helpButton.tap()
        //Tap Supported Formats button
        helpScreen.supportedFormatsLabel.tap()
        //Tap back button
        helpScreen.helpBackButton.tap()
        //Assert that Help screen is displayed
        XCTAssertTrue(helpScreen.cameraBackButton.isHittable)
    }
    
    func testHelpScreenImportDocumentsButton() {

        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Help button
        captureScreen.helpButton.tap()
        //Tap Import button
        helpScreen.importDocumentsLabel.tap()
        //Tap back button
        helpScreen.helpBackButton.tap()
        //Assert that Help screen is displayed
        XCTAssertTrue(helpScreen.cameraBackButton.isHittable)
    }

    /// PP-2273: no bottom-navigation view may render on the help screen.
    func testHelpScreenHasNoBottomNavigation() {

        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Help button
        captureScreen.helpButton.tap()

        //Assert no bottom-navigation view rendered on the help screen
        let bottomNavPredicate = NSPredicate(format:
            "identifier CONTAINS[c] 'bottomNav' OR label CONTAINS[c] 'BottomNavigation'")
        XCTAssertEqual(app.otherElements.matching(bottomNavPredicate).count,
                       0,
                       "No bottom-navigation view may render on the help screen after PP-2273")
    }
}

