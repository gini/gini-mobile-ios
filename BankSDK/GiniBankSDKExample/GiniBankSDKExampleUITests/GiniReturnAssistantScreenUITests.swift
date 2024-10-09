//
//  GiniReturnAssistantScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
/*
class GiniReturnAssistantScreenUITests: GiniBankSDKExampleUITests {
    
    /*
     To launch these tests and closely mimic real user behavior
     Please upload to device: 
        "Return Assistant Testrechnung" PDF file
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
        mainScreen.tapFileWithName(fileName: "Return Assistant Testrechnung")
        //Tap Open button
        captureScreen.openGalleryButton.tap()
        //Assert Get started button is displayed
        XCTAssertTrue(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 10))
        //Tap Get Started button
        returnAssistantScreen.getStartedButton.tap()
        //Tap Proceed button
        returnAssistantScreen.proceedButton.tap()
        //Tap Send feedback and close
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
        mainScreen.tapFileWithName(fileName: "Return Assistant Testrechnung")
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
        //Tap Send feedback and close
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
        mainScreen.tapFileWithName(fileName: "Return Assistant Testrechnung")
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
        //Tap Send feedback and close
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
        mainScreen.tapFileWithName(fileName: "Return Assistant Testrechnung")
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
        //Tap Send feedback and close
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
        mainScreen.tapFileWithName(fileName: "Return Assistant Testrechnung")
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
        //Tap Send feedback and close
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
        mainScreen.tapFileWithName(fileName: "Return Assistant Testrechnung")
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
        mainScreen.tapFileWithName(fileName: "Return Assistant Testrechnung")
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
*/
