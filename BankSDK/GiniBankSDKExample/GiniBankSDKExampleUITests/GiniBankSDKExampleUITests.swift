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
        copyFixturesToSimulator()
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

    /// Copies all PDFs from TestFixturePDFs/ into every booted simulator's app Documents folder.
    /// The UI test runner executes on the Mac host (not inside the simulator sandbox), so it has
    /// full access to ~/Library/Developer/CoreSimulator/. We scan all booted simulators rather
    /// than relying on SIMULATOR_UDID, which is not injected by Xcode into the test process.
    /// Copies all PDFs from TestFixturePDFs/ into the tested app's Documents folder.
    /// Xcode 15+ runs the test runner inside XCTestDevices, so NSHomeDirectory() returns:
    ///   .../XCTestDevices/{UDID}/data/Containers/Data/Application/{runner-UUID}
    /// Going one level up reaches the shared Application/ directory where all app containers
    /// for this test device live — including the tested app's container.
    private func copyFixturesToSimulator() {
        let fileManager = FileManager.default

        let applicationDir = URL(fileURLWithPath: NSHomeDirectory())
            .deletingLastPathComponent()
            .path

        guard let appFolders = try? fileManager.contentsOfDirectory(atPath: applicationDir) else { return }

        let fixturesURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()  // GiniBankSDKExampleUITests/
            .deletingLastPathComponent()  // GiniBankSDKExample/
            .appendingPathComponent("TestFixturePDFs")

        let pdfFiles = ((try? fileManager.contentsOfDirectory(at: fixturesURL,
                                                              includingPropertiesForKeys: nil,
                                                              options: .skipsHiddenFiles)) ?? [])
            .filter { $0.pathExtension == "pdf" }
        guard !pdfFiles.isEmpty else { return }

        for folder in appFolders {
            let metadataPath = "\(applicationDir)/\(folder)/.com.apple.mobile_container_manager.metadata.plist"
            guard let metadata = NSDictionary(contentsOfFile: metadataPath),
                  let bundleID = metadata["MCMMetadataIdentifier"] as? String,
                  bundleID == "net.gini.banksdk.example" else { continue }

            let docsURL = URL(fileURLWithPath: "\(applicationDir)/\(folder)/Documents")
            try? fileManager.createDirectory(at: docsURL, withIntermediateDirectories: true)
            for pdf in pdfFiles {
                let dest = docsURL.appendingPathComponent(pdf.lastPathComponent)
                try? fileManager.copyItem(at: pdf, to: dest)
            }
            return
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
