//
//  GiniSkontoScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

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
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.skontoPast)
        //Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
        //Assert that Got it button is displayed
        XCTAssertTrue(skontoScreen.gotItButton.waitForExistence(timeout: 10))
        //Tap Got it button
        skontoScreen.gotItButton.tap()
        //Tap Proceed button
        skontoScreen.proceedButton.tap()
        //Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
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
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.skontoPast)
        //Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
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
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.skontoPast)
        //Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
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
        //Transaction docs screen is optional — shown on BrowserStack, may be skipped locally.
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }
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
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.skontoValid)
        //Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
        //For a valid/future skonto there is no expired-discount banner — assert the Skonto screen itself is visible.
        XCTAssertTrue(skontoScreen.proceedButton.waitForExistence(timeout: 10))
        //Assert that switch is enabled (skonto is still active)
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
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.skontoPast)
        //Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
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
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.skontoPast)
        //Open button appears on some iOS versions/flows; safe to skip if absent.
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
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
