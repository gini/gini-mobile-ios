//
//  GiniBankSDKExampleUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import XCTest
import GiniCaptureSDK
import GiniBankSDK

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
    var transactionSummaryScreen: TransactionSummaryScreen!
    var noResultsScreen: NoResultsScreen!
    var cxExtractionScreen: CXExtractionScreen!
    var isSimulator = true
    
    override func setUpWithError() throws {
        
        if isSimulator {
            throw XCTSkip("Skipping test")
        }
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-testing"]
        app.launchArguments = ["-StartFromCleanState", "YES"]
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
        transactionSummaryScreen = TransactionSummaryScreen(app: app, locale: currentLocale)
        noResultsScreen = NoResultsScreen(app: app, locale: currentLocale)
        cxExtractionScreen = CXExtractionScreen(app: app)
    }
    
    override func tearDownWithError() throws  {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        if !isSimulator {
            attachment.lifetime = .deleteOnSuccess
            add(attachment)
            app.terminate()
        }
    }

    var galleryTitle: String {
        switch Locale.current.languageCode ?? "en" {
        case "de": return "Alben"
        default:   return "Albums"
        }
    }

    var analysisScreenTitle: String {
        switch Locale.current.languageCode ?? "en" {
        case "de": return "Auswertung"
        default:   return "Analysis"
        }
    }

    var analysisLoadingText: String {
        switch Locale.current.languageCode ?? "en" {
        case "de": return "Dokument wird analysiert"
        default:   return "Analyzing documents"
        }
    }

    var galleryDoneButtonTitle: String {
        switch Locale.current.languageCode ?? "en" {
        case "de": return "Fertig"
        default:   return "\u{0010}Done"
        }
    }

    func tapDoneInAnyKnownContext() {
        switch Locale.current.languageCode ?? "en" {
        case "de": app.buttons["Fertig"].firstMatch.tap()
        default:   app.buttons["\u{0010}Done"].firstMatch.tap()
        }
    }

    func waitForAnalysisIfNeeded() {
        let analysisIndicators = [
            app.navigationBars[analysisScreenTitle],
            app.staticTexts[analysisLoadingText],
            app.staticTexts[analysisScreenTitle]
        ]
        if !analysisIndicators.contains(where: { $0.waitForExistence(timeout: 2) }) { return }
        for indicator in analysisIndicators where indicator.exists {
            let gonePredicate = NSPredicate(format: "exists == false")
            let expectation = XCTNSPredicateExpectation(predicate: gonePredicate, object: indicator)
            let result = XCTWaiter().wait(for: [expectation], timeout: 30)
            if result != .completed { XCTFail("Analysis screen did not disappear within timeout") }
        }
    }

    func uploadLatestPhotoFromGallery() {
        XCTAssertTrue(app.navigationBars[galleryTitle].waitForExistence(timeout: 10))
        app.tables.cells.firstMatch.tap()
        let imageCells = app.collectionViews.cells
        XCTAssertTrue(imageCells.firstMatch.waitForExistence(timeout: 10))
        guard let latestVisibleImage = imageCells.allElementsBoundByIndex.last else {
            XCTFail("No gallery image was found to upload.")
            return
        }
        latestVisibleImage.tap()
        XCTAssertTrue(app.buttons[galleryDoneButtonTitle].firstMatch.waitForExistence(timeout: 10))
        tapDoneInAnyKnownContext()
    }
}
