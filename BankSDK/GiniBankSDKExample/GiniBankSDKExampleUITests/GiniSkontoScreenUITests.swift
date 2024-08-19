//
//  GiniSkontoScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class GiniSkontoScreenUITests: GiniBankSDKExampleUITests {
    
    func testSkonto() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload photo button
        captureScreen.uploadFilesButton.tap()
        //tap Skonto document
        mainScreen.tapFileWithName(fileName: "PNG image")
        //tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Process button
        reviewScreen.processButton.tap()
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Tap Got it button
        skontoScreen.gotItButton.tap()
        //Tap Proceed button
        skontoScreen.proceedButton.tap()
        //Tap Send feedback and close
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
}
