//
//  GiniSkontoScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// All the test methods have "manual" as a prefix because the tests require preparation of simulators to include a specific file.
// Please remove the prefix if you want to test locally on a simulator

class GiniSkontoScreenUITests: GiniBankSDKExampleUITests {

    /*
     To launch these tests and closely mimic real user behavior
     Please upload to device:
        "skonto_past" file with expired skonto
        "skonto_valid" file with valid skonto
     */
    let skontoPastFileName = "skonto_past"
    let skontoValidFileName = "skonto_valid"
    
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
        mainScreen.tapFileWithName(fileName: skontoPastFileName)
        //tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Tap Got it button
        skontoScreen.gotItButton.tap()
        //Tap Proceed button
        skontoScreen.proceedButton.tap()
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testSkontoBackButton() {
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
        mainScreen.tapFileWithName(fileName: skontoPastFileName)
        //tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Tap Got it button
        skontoScreen.gotItButton.tap()
        //Tap Back button
        skontoScreen.backButtonNavigation.tap()
        //Assert Capture button is displayed
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }
    
    func testSkontoSwitch() {
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
        mainScreen.tapFileWithName(fileName: skontoPastFileName)
        //tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Tap Got it button
        skontoScreen.gotItButton.tap()
        //Assert that Switch is disabled
        XCTAssertTrue((skontoScreen.skontoSwitch.value != nil), "0")
        //Enable Skonto switch
        skontoScreen.skontoSwitch.tap()
        //Assert that Switch is enabled
        XCTAssertTrue((skontoScreen.skontoSwitch.value != nil), "1")
        //Tap Proceed button
        skontoScreen.proceedButton.tap()
        //Tap Only for this transaction
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    
    func testSkontoInFuture() {
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
        mainScreen.tapFileWithName(fileName: skontoValidFileName)
        //tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Assert that Switch is disabled
        XCTAssertTrue((skontoScreen.skontoSwitch.value != nil), "1")
    }
    
    func testSkontoInPast() {
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
        mainScreen.tapFileWithName(fileName: skontoPastFileName)
        //tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Assert that Switch is disabled
        XCTAssertTrue((skontoScreen.skontoSwitch.value != nil), "0")
    }
    
    func testSkontoHelpButtonbo() {
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
        mainScreen.tapFileWithName(fileName: skontoPastFileName)
        //tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Tap Got it button
        skontoScreen.gotItButton.tap()
        //Tap Help button
        skontoScreen.helpButton.tap()
        //Assert Proceed button isn't displayed
        XCTAssertFalse(skontoScreen.proceedButton.isHittable)
    }
}
