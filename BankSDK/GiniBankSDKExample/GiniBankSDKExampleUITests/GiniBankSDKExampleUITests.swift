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
    
    func initializeSettingScreen() -> SettingScreen {
        return SettingScreen(app: app)
    }
    
    func initializeCaptureScreen() -> CaptureScreen {
        return CaptureScreen(app: app)
    }
    
    func initializeHelpScreen() -> HelpScreen {
        return HelpScreen(app: app)
    }
}
