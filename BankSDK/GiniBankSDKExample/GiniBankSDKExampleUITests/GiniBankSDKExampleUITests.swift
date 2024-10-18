//
//  GiniBankSDKExampleUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import XCTest
@testable import GiniCaptureSDK
@testable import GiniBankSDK

class GiniBankSDKExampleUITests: XCTestCase {

    var app: XCUIApplication!
    var mainScreen: MainScreen!
    var helpScreen: HelpScreen!
    var settingScreen: SettingScreen!
    var captureScreen: CaptureScreen!
    var errorScreen: ErrorScreen!
    var cameraAccessScreen: CameraAccessScreen!
    var onboadingScreen: OnboardingScreen!
    var skontoScreen: SkontoScreen!
    var returnAssistantScreen: ReturnAssistantScreen!
    var reviewScreen: ReviewScreen!
    var transactionDocsScreen: TransactionDocsScreen!
    var isSimulator = true
    
    override func setUpWithError() throws {
        
        if isSimulator == true { throw XCTSkip("Skipping test") }
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-testing"]
        app.launch()
        //Initialize Identifiers based on current locale
        let currentLocale = Locale.current.languageCode ?? "en"
        mainScreen = MainScreen(app: app, locale: currentLocale)
        helpScreen = HelpScreen(app: app, locale: currentLocale)
        settingScreen = SettingScreen(app: app, locale: currentLocale)
        captureScreen = CaptureScreen(app: app, locale: currentLocale)
        errorScreen = ErrorScreen(app: app, locale: currentLocale)
        cameraAccessScreen = CameraAccessScreen(app: app, locale: currentLocale)
        onboadingScreen = OnboardingScreen(app: app, locale: currentLocale)
        skontoScreen = SkontoScreen(app: app, locale: currentLocale)
        returnAssistantScreen = ReturnAssistantScreen(app: app, locale: currentLocale)
        reviewScreen = ReviewScreen(app: app, locale: currentLocale)
        transactionDocsScreen = TransactionDocsScreen(app: app, locale: currentLocale)
    }
    
    override func tearDownWithError() throws  {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        if isSimulator == false {
            attachment.lifetime = .deleteOnSuccess
            add(attachment)
            app.terminate()
        }
    }
}
