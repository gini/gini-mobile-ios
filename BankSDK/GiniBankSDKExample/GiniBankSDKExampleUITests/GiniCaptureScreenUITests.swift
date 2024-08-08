//
//  GiniCaptureScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest

class GiniCaptureScreenUITests: GiniBankSDKExampleUITests {
    
    func testCancelButtonInMenu() throws {
        
        //No Cancel button on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
               throw XCTSkip("Skipping test on iPad")
           }
        //Tap Photopayment button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Skip onboarding
        onboadingScreen.skipOnboardingScreens()
        //Tap Files button
        captureScreen.filesButton.tap()
        //Tap Cancel button
        captureScreen.cancelButtonInMenu.tap()
        //Assert Cancel button isn't displayed
        XCTAssertFalse(captureScreen.cancelButtonInMenu.isHittable)
    }
    
    func testUploadFilesButtonInMenu() {
        
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
        //Assert Cancel button isn't displayed
        XCTAssertFalse(captureScreen.cancelButtonInMenu.isHittable)
    }
    
    func testUploadPhotosButtonInMenu() {
        
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
    //Assert is commented for now because of Photo Permission pop up
        //Assert Capture button isn't displayed
        //XCTAssertFalse(captureScreen.captureButton.isHittable)
    }
}

