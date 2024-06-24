    //
    //  GiniBankSDKExampleUITests.swift
    //
    //  Copyright © 2024 Gini GmbH. All rights reserved.
    //


import XCTest
final class GiniBankSDKExampleUITests: XCTestCase {
    
    let app = XCUIApplication()
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testing"]
        app.launch()
    }
    
    override func tearDown() {
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.lifetime = .deleteOnSuccess
            add(attachment)
            app.terminate()
        }
    
    
    func testCancelButtonExists() throws {
        let mainScreen = MainScreen(app:app)
        mainScreen.initiateApp()
        mainScreen.tapCancelButton()
    }
    
    func testFlashConfiguration() throws {
        let mainScreen = MainScreen(app:app)
        let configurationScreen = ConfigurationScreen(app: app)
        configurationScreen.tapFlashToggleConfiguration()
        mainScreen.initiateApp()
        XCTAssertFalse(configurationScreen.flashButton.exists, "Does not exists")
    }
    
    func testCaptureDocument() throws {
        let mainScreen = MainScreen(app:app)
        let captureScreen = CaptureScreen(app: app)
        mainScreen.initiateApp()
        captureScreen.tapCaptureButton()
    }
    
    func testHelpItemExists() throws {
        let mainScreen = MainScreen(app:app)
        let helpScreen = HelpScreen(app: app)
        mainScreen.initiateApp()
        helpScreen.tapHelpButtonAndTipsItem()
    }
    
    func testDigitalInvoice() throws{
        let mainScreen = MainScreen(app:app)
        let captureScreen = CaptureScreen(app: app)
        let digitalInvoiceScreen = DigitalInvoiceScreen(app: app)
        
        mainScreen.initiateApp()
        captureScreen.tapCaptureButton()
        digitalInvoiceScreen.tapProceedButton()
    }
    
    func testSendFeedback() throws{
        let mainScreen = MainScreen(app:app)
        let captureScreen = CaptureScreen(app: app)
        let digitalInvoiceScreen = DigitalInvoiceScreen(app: app)
        let extractionScreen = ExtractionScreen(app: app)
        
        mainScreen.initiateApp()
        captureScreen.tapCaptureButton()
        digitalInvoiceScreen.tapProceedButton()
        extractionScreen.tapFeedbackButton()
        mainScreen.assertMainScreenTitle()
    }
}
