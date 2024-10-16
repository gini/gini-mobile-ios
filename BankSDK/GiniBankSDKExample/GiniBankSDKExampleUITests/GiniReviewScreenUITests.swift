//
//  GiniReviewScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// All the test methods have "manual" as a prefix because the tests require preparation of simulators to include a specific file.
// Please remove the prefix if you want to test locally on a simulator

class GiniReviewScreenUITests: GiniBankSDKExampleUITests {
    
    /*
     To launch these tests and closely mimic real user behavior
     Please upload to device:
        "test_image" image file with invoice
     */
    
    func manualTestAddPageButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload Files button
        captureScreen.uploadFilesButton.tap()
        //Tap Skonto document
        mainScreen.tapFileWithName(fileName: "test_image")
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Add page button
        reviewScreen.addPageButton.tap()
        //Assert that Capture button is displayed
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
    }
    
    func manualTestProcessButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload Files button
        captureScreen.uploadFilesButton.tap()
        //Tap Skonto document
        mainScreen.tapFileWithName(fileName: "test_image")
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Process button
        reviewScreen.processButton.tap()
        //Assert that Capture button is displayed
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
    }
    
    func manualTestCancelButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload Files button
        captureScreen.uploadFilesButton.tap()
        //Tap Skonto document
        mainScreen.tapFileWithName(fileName: "test_image")
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Cancel button
        reviewScreen.backButtonNavigation.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }
    
    func manualTestDeleteButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload Files button
        captureScreen.uploadFilesButton.tap()
        //Tap Skonto document
        mainScreen.tapFileWithName(fileName: "test_image")
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Process button
        reviewScreen.deleteButton.tap()
        //Assert that Capture button is displayed
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
    }
}