//
//  GiniOnboardingScreenUITest.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest
import GiniBankSDK


class GiniOnboardingScreenUITest: GiniBankSDKExampleUITests {
    
    /*
     Preconditions update required
     */

    func testOnboardingGetStartedButton() throws {
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Onboarding screens at every launch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
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
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
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
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
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

    /// The top-navigation Skip control must be the only skip path;
    /// no `skipBottomBar*` / `bottomNavigation*` element may render.
    func testOnboardingSkipButtonIsTopNavOnly() throws {
    //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
        settingScreen.closeButton.tap()

    //Test Case
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Tap Next button
        onboadingScreen.nextButton.tap()

        //Assert the top-nav Skip button is hittable
        XCTAssertTrue(onboadingScreen.skipButton.isHittable,
                      "Top-nav Skip button must be the sole skip control")

        //Assert no bottom-nav / skipBottomBar element rendered
        let bottomNavPredicate = NSPredicate(format:
            "identifier CONTAINS[c] 'bottomNav' OR identifier CONTAINS[c] 'skipBottomBar'")
        XCTAssertEqual(app.buttons.matching(bottomNavPredicate).count,
                       0,
                       "No element whose identifier contains 'bottomNav' or 'skipBottomBar' may exist — the bottom-nav surface is not supported")
    }

    func testOnboardingSwipePages() throws {
        //Preconditions
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
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
        //Tap Get Started button
        onboadingScreen.getStartedButton.tap()
        //Assert Take picture button is displayed
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }

    // PP-3411: Slide through the 4 onboarding screens back and forth
    func testOnboardingSwipeForwardAndBackThroughAllPages() throws {
        openOnboarding()
        //Swipe forward to the last page
        onboadingScreen.swipeToNextPage()
        onboadingScreen.waitForPage(onboadingScreen.goodLightingTitle)
        onboadingScreen.swipeToNextPage()
        onboadingScreen.waitForPage(onboadingScreen.multiPagesTitle)
        onboadingScreen.swipeToNextPage()
        onboadingScreen.waitForPage(onboadingScreen.qrCodeTitle)
        //Assert the last page shows Get Started and no Skip button
        XCTAssertTrue(onboadingScreen.getStartedButton.exists)
        XCTAssertFalse(onboadingScreen.skipButton.exists)
        //Swipe back to the first page
        onboadingScreen.swipeToPreviousPage()
        onboadingScreen.waitForPage(onboadingScreen.multiPagesTitle)
        //Assert Skip is back and Get Started is gone
        XCTAssertTrue(onboadingScreen.skipButton.exists)
        XCTAssertFalse(onboadingScreen.getStartedButton.exists)
        onboadingScreen.swipeToPreviousPage()
        onboadingScreen.waitForPage(onboadingScreen.goodLightingTitle)
        onboadingScreen.swipeToPreviousPage()
        onboadingScreen.waitForPage(onboadingScreen.flatPaperTitle)
    }

    // PP-3412: Skip after the first screen ("Flat paper within the frame")
    func testOnboardingSkipOnFirstPageOpensCamera() throws {
        openOnboarding()
        //Tap Skip button
        onboadingScreen.tapSkip()
        //Assert Take picture button is displayed
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10))
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }

    // PP-3414: Skip after the third screen ("Add multiple pages")
    func testOnboardingSkipOnThirdPageOpensCamera() throws {
        openOnboarding()
        //Go to the third page
        onboadingScreen.tapNextAndWaitFor(onboadingScreen.goodLightingTitle)
        onboadingScreen.tapNextAndWaitFor(onboadingScreen.multiPagesTitle)
        //Tap Skip button
        onboadingScreen.tapSkip()
        //Assert Take picture button is displayed
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10))
        XCTAssertTrue(captureScreen.captureButton.isHittable)
    }

    /**
     Shows the onboarding on its first page, with the same preconditions as the tests above:
     onboarding at every launch on, at first launch off, camera access allowed.
     */
    private func openOnboarding() {
        //Open settings screen
        mainScreen.configurationButton.tap()
        //Enable Onboarding at every launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingEveryLaunchSwitch, enabled: true)
        //Disable Onboarding at first launch switch
        mainScreen.tapSwitchNextToTextElement(text: settingScreen.onboardingAtFirstLaunchSwitch, enabled: false)
        settingScreen.closeButton.tap()
        //Tap Photopaymen button
        mainScreen.photoPaymentButton.tap()
        //Handle Camera access pop up
        mainScreen.handleCameraPermission(answer: true)
        //Assert the first page is shown
        onboadingScreen.waitForPage(onboadingScreen.flatPaperTitle,
                                    timeout: OnboardingScreen.Constants.firstPageTimeout)
    }
}
