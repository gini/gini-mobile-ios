//
//  GiniReviewScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest


class GiniReviewScreenUITests: GiniBankSDKExampleUITests {
    /*
     To launch these tests and closely mimic real user behavior
     Please upload to device:
        "test_image" PDF/PNG file with invoice
     */

    // PDF file needed
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.testImage)
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.testImage)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton)
        //Tap Process button
        reviewScreen.processButton.tap()
        //Tap Only for this transaction
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.testImage)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Cancel button
        reviewScreen.backButtonNavigation.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }
    
    /// PP-2273: no bottom-navigation view may render on the review screen.
    /// Manual test — mirrors `manualTestProcessButton`'s setup because it
    /// requires the same PDF upload precondition documented at the top of
    /// this suite.
    func manualTestReviewScreenHasNoBottomNavigationRendered() {
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.testImage)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))

        //Assert no bottom-navigation view rendered
        let bottomNavPredicate = NSPredicate(format:
            "identifier CONTAINS[c] 'bottomNav' OR label CONTAINS[c] 'BottomNavigation'")
        XCTAssertEqual(app.otherElements.matching(bottomNavPredicate).count,
                       0,
                       "No bottom-navigation view may render on the review screen after PP-2273")
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
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.testImage)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Process button
        reviewScreen.deleteButton.tap()
        //Assert that Capture button is displayed
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
    }

    // MARK: BrowserStack testing methods
    // PNG file needed

    private func accessLatestPhotoFromGallery() {
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()
    }

    func testAddPageButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        accessLatestPhotoFromGallery()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Add page button
        reviewScreen.addPageButton.tap()
        //Assert that Capture button is displayed
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
    }

    func testProcessButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        accessLatestPhotoFromGallery()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton)
        //Tap Process button
        reviewScreen.processButton.tap()
        //Tap Only for this transaction
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Capture button is displayed
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
    }

    func testCancelButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        accessLatestPhotoFromGallery()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Cancel button
        reviewScreen.backButtonNavigation.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5))
    }

    func testDeleteButton() {
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        accessLatestPhotoFromGallery()
        //Assert that Proceed button is displayed
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 10))
        //Tap Process button
        reviewScreen.deleteButton.tap()
        //Assert that Capture button is displayed
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 5))
    }
}
