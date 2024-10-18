//
//  GiniOnboardingScreenUITest.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest
import GiniBankSDK


class GiniOnboardingScreenUITest: GiniBankSDKExampleUITests {

    func testOnboardingGetStartedButton() throws {
    
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Onboarding screens at every launch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch", enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at first launch", enabled: false)
        settingScreen.closeButton.tap()
    //Test Case
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Tap Get Started button
        onboadingScreen.getStartedButton.tap()
        //Assert Take pickrute button is displayed
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }
    
    func testOnboardingSkipButton() throws {
    
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Bottom navigation bar
        mainScreen.tapSwitchNextToTextElement(text: "Bottom navigation bar", enabled: true)
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch", enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at first launch", enabled: false)
        settingScreen.closeButton.tap()
    //Test Case
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Tap Skip button
        onboadingScreen.skipButton.tap()
        //Assert Take pickrute button is displayed
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }

    func testOnboardingSwipeAction() throws {
        
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Bottom navigation bar
        mainScreen.tapSwitchNextToTextElement(text: "Bottom navigation bar", enabled: true)
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch", enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at first launch", enabled: false)
        settingScreen.closeButton.tap()
    //Test Case
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Swipe Left
        app.swipeLeft()
        //Tap Get Started butto
        onboadingScreen.getStartedButton.tap()
        //Assert Take pickrute button is displayed
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }


    /*
     // this method is commented until Vlad will fix the issue with small devices screen size
    func testOnboardingSwipeActionBottomNavBar() throws {
        
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Bottom navigation bar
        mainScreen.tapSwitchNextToTextElement(text: "Bottom navigation bar", enabled: true)
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch", enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at first launch", enabled: false)
        settingScreen.closeButton.tap()
    //Test Case
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Tap Next button
        onboadingScreen.nextButton.tap()
        //Swipe Left
        app.swipeLeft()
        //Tap Get Started butto
        onboadingScreen.getStartedButton.tap()
        //Assert Take pickrute button is displayed
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }
     */
    /*
     // this method is commented until Vlad will fix the issue with small devices screen size
    func testOnboardingSwipeActionCustomBottomNavBar() throws {
        
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Bottom navigation bar
        mainScreen.tapSwitchNextToTextElement(text: "Bottom navigation bar", enabled: true)
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch", enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at first launch", enabled: false)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding custom bottom navigation bar", enabled: true)
        settingScreen.closeButton.tap()
    //Test Case
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Tap Next button
        onboadingScreen.nextButtonCustom.tap()
        //Tap Next button
        onboadingScreen.nextButtonCustom.tap()
        //Swipe Left
        app.swipeLeft()
        //Tap Get Started butto
        onboadingScreen.nextButtonCustom.tap()
        //Assert Take pickrute button is displayed
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }
     */
}
