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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.skontoPast)
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
    
    
    /**

     Pre-condition: add the `skonto_past` image (PNG or JPG) to the simulator's
     photo library before running this test. The method picks the **last** photo
     in the library, so make sure the skonto image is the most recently added one.
     */
    func testSkontoUsingGallery() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button to open the upload menu
        captureScreen.filesButton.tap()
        //Tap Upload photo button to open the photo library picker
        captureScreen.uploadPhotoButton.tap()
        //Handle photo library permission alert if it appears
        mainScreen.handlePhotoPermission(answer: true)
        //Select the latest photo from the gallery (skonto_past image)
        uploadLatestPhotoFromGallery()
        //Wait for ReviewViewController and tap Process to trigger analysis
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton)
        reviewScreen.processButton.tap()
        //Wait for analysis screen to finish if it appears
        waitForAnalysisIfNeeded()
        //Tap Got it button if the edge-case alert is displayed (only shown for expired/today/cash skonto)
        if skontoScreen.gotItButton.waitForExistence(timeout: 10) {
            skontoScreen.gotItButton.tap()
        }
        //Assert Skonto confirm button is visible and tap it
        XCTAssertTrue(skontoScreen.proceedButton.waitForExistence(timeout: 5))
        skontoScreen.proceedButton.tap()
        //Tap Only for this transaction if TransactionDocs bottom sheet appears (skipped if preference already saved)
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
        //Tap Done / Send feedback
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.skontoPast)
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.skontoPast)
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.skontoValid)
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.skontoPast)
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.skontoPast)
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
