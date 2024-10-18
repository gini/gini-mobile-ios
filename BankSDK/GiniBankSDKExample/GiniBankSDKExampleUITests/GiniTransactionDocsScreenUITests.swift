//
//  GiniTransactionDocsScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class GiniTransactionDocsScreenUITests: GiniBankSDKExampleUITests {
    
    /*
     To launch these tests and closely mimic real user behavior
     Please upload to device:
        "test_image" image file with invoice
     */
    
    func testDontAttach() {
        
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
        //Tap Dont Attach button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.dontAttach.tap()
        //Assert that Document is NOT displayed
        XCTAssertFalse(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
    
    func testAttachOnlyThisTransaction() {
        
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
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
    
    func testAlwaysAttach() {
        
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
        //Tap Always attach transaction
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10))
        transactionDocsScreen.alwaysAttach.tap()
        //Assert that Sent Feedback button is displayed
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        //Tap Send Feedback button
        mainScreen.sendFeedbackButton.tap()
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
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
        //Restore User Defaults
        mainScreen.sendFeedbackButton.tap()
        mainScreen.configurationButton.tap()
        app.staticTexts["Remove from UserDefaults"].tap()
        
    }
    
    func testDeleteDocumentFromExtractions() {
        
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
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
        //Tap Edit button
        transactionDocsScreen.editButton.tap()
        //Tap Delete button
        transactionDocsScreen.deleteButton.tap()
        //Assert Document is NOT displayed
        XCTAssertFalse(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
    
    func testOpenDocument() {
        
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
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
        //Tap Document name
        transactionDocsScreen.documentName.tap()
        //Assert Document name title is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
    
    func testDeleteDocumentFromPreview() {
        
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
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
        //Tap Document name
        transactionDocsScreen.documentName.tap()
        //Tap Edit button
        transactionDocsScreen.editButtonPreview.tap()
        //Tap Delete button
        transactionDocsScreen.deleteButton.tap()
        //Assert Document is NOT displayed
        XCTAssertFalse(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
    
    func testEditMenuCancelButtonExtractionScreen() throws {
        
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
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
        //Tap Edit button
        transactionDocsScreen.editButton.tap()
        //Tap Cancel button
        if UIDevice.current.userInterfaceIdiom == .pad {
               throw XCTSkip("Skipping test on iPad")
           }
        transactionDocsScreen.cancelButton.tap()
        //Assert Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
    
    func testEditMenuCancelButtonPreviewScreen() throws {
        
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
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
        //Tap Document name
        transactionDocsScreen.documentName.tap()
        //Tap Edit button
        if UIDevice.current.userInterfaceIdiom == .pad {
               throw XCTSkip("Skipping test on iPad")
           }
        transactionDocsScreen.editButtonPreview.tap()
        //Tap Cancel button
        captureScreen.cancelButtonInMenu.tap()
        //Assert Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
    
    func testBackButtonFromPreviewScreen() {
        
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
        //Tap Only for this transaction button
        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5))
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Assert that Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
        //Tap Document name
        transactionDocsScreen.documentName.tap()
        //Tap Cancel button
        transactionDocsScreen.cancelButton.tap()
        //Assert Document is displayed
        XCTAssertTrue(transactionDocsScreen.documentName.waitForExistence(timeout: 5))
    }
}

