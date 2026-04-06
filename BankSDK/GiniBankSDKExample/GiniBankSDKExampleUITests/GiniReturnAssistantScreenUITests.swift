//
//  GiniReturnAssistantScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

// All the test methods have "manual" as a prefix because the tests require preparation of simulators to include a specific file.
// Please remove the prefix if you want to test locally on a simulator

class GiniReturnAssistantScreenUITests: GiniBankSDKExampleUITests {
    
    /*
     To launch these tests and closely mimic real user behavior
     Please upload to device: 
        "ReturnAssistantTestrechnung" PDF file
        a return assistant sample image to the Photos library for the gallery flow test
     */

    func testReturnAssistant() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload files button
        captureScreen.uploadFilesButton.tap()
        //Tap RA document
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.returnAssistant)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Proceed button
        returnAssistantScreen.proceedButton.tap()
        //Tap Only for this transaction
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testReturnAssistantGalleryUpload() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload photo button
        captureScreen.uploadPhotoButton.tap()
        //Handle Photos access pop up
        mainScreen.handlePhotoPermission(answer: true)
        //Select and upload a photo from the gallery
        uploadLatestPhotoFromGallery()
        //Wait for review screen and tap Process
        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()
        //Wait for analysis screen to go away if it appears
        waitForAnalysisIfNeeded()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 30))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Proceed button
        returnAssistantScreen.proceedButton.tap()
        //Tap Only for this transaction
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testReturnAssistantEditName() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload files button
        captureScreen.uploadFilesButton.tap()
        //Tap RA document
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.returnAssistant)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Edit button
        returnAssistantScreen.editButton.firstMatch.tap()
        //Type text in Name field
        mainScreen.clearInputField(element: returnAssistantScreen.nameTextField)
        returnAssistantScreen.nameTextField.tap()
        returnAssistantScreen.nameTextField.typeText("New Product")
        //Tap Save button
        returnAssistantScreen.saveButton.tap()
        //Assert New Product static text is displayed
        XCTAssertTrue(app.staticTexts["1x New Product"].waitForExistence(timeout: 1))
        //Tap Proceed button
        returnAssistantScreen.proceedButton.tap()
        //Tap Only for this transaction
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testReturnAssistantEditPrice() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload files button
        captureScreen.uploadFilesButton.tap()
        //Tap RA document
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.returnAssistant)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Edit button
        returnAssistantScreen.editButton.firstMatch.tap()
        //Type value in Price field
        mainScreen.clearInputField(element: returnAssistantScreen.priceTextField)
        returnAssistantScreen.priceTextField.tap()
        returnAssistantScreen.priceTextField.typeText("123")
        //Tap Save button
        returnAssistantScreen.saveButton.tap()
        //Tap Edit button
        returnAssistantScreen.editButton.firstMatch.tap()
        //Save value form Price input field
        let value = returnAssistantScreen.priceTextField.value
        //Tap Save button
        returnAssistantScreen.saveButton.tap()
        //Assert new price displayed
        mainScreen.assertTextIsDisplayedInAnyStaticText(expectedText: value as! String)
        //Tap Proceed button
        returnAssistantScreen.proceedButton.tap()
        //Tap Only for this transaction
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testReturnAssistantEditQuantity() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload files button
        captureScreen.uploadFilesButton.tap()
        //Tap RA document
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.returnAssistant)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Edit button
        returnAssistantScreen.editButton.firstMatch.tap()
        //Type text in Name field
        mainScreen.clearInputField(element: returnAssistantScreen.nameTextField)
        returnAssistantScreen.nameTextField.tap()
        returnAssistantScreen.nameTextField.typeText("New Product")
        //Tap Fertig
        returnAssistantScreen.doneKeyboard.tap()
        //Tap plus button
        returnAssistantScreen.plusButton.tap()
        //Tap plus button
        returnAssistantScreen.plusButton.tap()
        //Tap minus button
        returnAssistantScreen.minusButton.tap()
        //Tap Save button
        returnAssistantScreen.saveButton.tap()
        //Assert New Product static text is displayed
        XCTAssertTrue(app.staticTexts["2x New Product"].waitForExistence(timeout: 1))
        //Tap Proceed button
        returnAssistantScreen.proceedButton.tap()
        //Tap Only for this transaction
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testReturnAssistantDisableSwitch() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload files button
        captureScreen.uploadFilesButton.tap()
        //Tap RA document
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.returnAssistant)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Switch button
        app.switches.firstMatch.tap()
        //Tap Proceed button
        returnAssistantScreen.proceedButton.tap()
        //Tap Only for this transaction
        transactionDocsScreen.onlyForThisTransaction.tap()
        //Tap Send feedback and close
        XCTAssertTrue(mainScreen.sendFeedbackButton.waitForExistence(timeout: 5))
        mainScreen.sendFeedbackButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testReturnAssistantCancelButton() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload files button
        captureScreen.uploadFilesButton.tap()
        //Tap RA document
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.returnAssistant)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Cancel button
        returnAssistantScreen.cancelButtonNavigation.tap()
        //Assert Photopayment button is displayed
        XCTAssertTrue(mainScreen.photoPaymentButton.isHittable)
    }
    
    func testReturnAssistantHelpButton() {
        
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Upload files button
        captureScreen.uploadFilesButton.tap()
        //Tap RA document
        mainScreen.tapFileWithName(fileName: TestFixtures.Files.returnAssistant)
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Cancel button
        returnAssistantScreen.helpButton.tap()
        //Assert Photopayment button is displayed
        XCTAssertFalse(returnAssistantScreen.proceedButton.isHittable)
    }
}
