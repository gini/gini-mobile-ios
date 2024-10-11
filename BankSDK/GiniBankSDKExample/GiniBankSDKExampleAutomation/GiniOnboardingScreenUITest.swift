//
//  GiniOnboardingScreenUITest.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

//import Foundation
//import XCTest
//import GiniBankSDK

/*
class GiniOnboardingScreenUITest: GiniBankSDKExampleUITests {

    func testOnboardingGetStartedButton() throws {
    
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Onboarding screens at every launch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch")
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingAtFirstLaunchSwitch,direction: "up")
        //Disable Onboarding at first launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingAtFirstLaunchSwitch,
                                              enabled: false)
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
        //Enable Onboarding screens at every launch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch")
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingAtFirstLaunchSwitch, direction: "up")
        //Disable Onboarding at first launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
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
        //Enable Onboarding screens at every launch
        mainScreen.tapSwitchNextToTextElement(text: "Onboarding screens at every launch")
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingAtFirstLaunchSwitch, direction: "up")
        //Disable Onboarding at first launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
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
    
    func testOnboardingSwipeActionBottomNavBar() throws {
        
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Bottom navigation bar
        mainScreen.tapSwitchNextToTextElement(text: "Bottom navigation bar")
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingEveryLaunchSwitch, direction: "up")
        //Enable Onboarding at every launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingAtFirstLaunchSwitch, direction: "up")
        //Disable Onboarding at first launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
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
    
    func testOnboardingSwipeActionCustomBottomNavBar() throws {
        
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Bottom navigation bar
        mainScreen.tapSwitchNextToTextElement(text: "Bottom navigation bar")
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingEveryLaunchSwitch, direction: "up")
        //Enable Onboarding at every launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingAtFirstLaunchSwitch, direction: "up")
        //Disable Onboarding at first launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
        //Scroll to element
        mainScreen.swipeToElement(element: settingScreen.onboardingCustomBottomNavBar, direction: "up")
        //Disable Onboarding at first launch switch
        mainScreen.handleConfigurationSetting(element: settingScreen.onboardingCustomBottomNavBar, enabled: true)
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
}
*/
