//
//  GiniBankSDKExampleUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import GiniCaptureSDK
import XCTest

class GiniBankSDKExampleUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
    
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["testing"]
        app.launch()
        print("we launch app")
    }
    
    override func tearDown() {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
        app.terminate()
        super.tearDown()
    }
    
    func initializeMainScreen() -> MainScreen {
        return MainScreen(app: app)
    }
    
    func initializeConfigurationScreen() -> ConfigurationScreen {
        return ConfigurationScreen(app: app)
    }
    
    func initializeCaptureScreen() -> CaptureScreen {
        return CaptureScreen(app: app)
    }
    
    func initializeHelpScreenz() -> HelpScreen {
        return HelpScreen(app: app)
    }
}
