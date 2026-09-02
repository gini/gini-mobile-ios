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
    var creditNoteWarningScreen: CreditNoteWarningScreen!
    var paymentHintScreen: PaymentHintScreen!


    /**
     Class-level launch args, added on setUp and every `relaunch()`. Override in subclasses.
     */
    var additionalLaunchArguments: [String] { [] }

    /**
     Per-test launch args. Assign before `relaunch()`; cleared in tearDown.
     */
    var extraLaunchArguments: [String] = []

    /**
     Base + class-level + per-test launch arguments.
     */
    private var currentLaunchArguments: [String] {
        ["-StartFromCleanState", "YES"] + additionalLaunchArguments + extraLaunchArguments
    }

    /**
     Terminates the app and re-launches it with `currentLaunchArguments`.
     */
    func relaunch() {
        app.terminate()
        app.launchArguments = currentLaunchArguments
        app.launch()
    }

    override func setUpWithError() throws {
        // Simulator skip disabled so the suite runs on BrowserStack — re-enable to
        // guard local simulator runs again.
         #if targetEnvironment(simulator)
             throw XCTSkip("Skipping test on simulator")
         #endif
        continueAfterFailure = false
        copyFixturesToSimulator()
        app = XCUIApplication()
        app.resetAuthorizationStatus(for: .camera)
        app.resetAuthorizationStatus(for: .photos)
        app.launchArguments = currentLaunchArguments
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
        creditNoteWarningScreen = CreditNoteWarningScreen(app: app, locale: currentLocale)
        paymentHintScreen = PaymentHintScreen(app: app)
    }
    
    override func tearDownWithError() throws  {
    #if !targetEnvironment(simulator)
        // Always terminate the app and attach failure screenshots on both simulator and device.
        // This prevents state leakage between test runs and ensures diagnostic screenshots are available.
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
        app.terminate()
    #endif // !targetEnvironment(simulator)
        extraLaunchArguments = []
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

    /**
     Picker's confirm button — text "Done"/"Fertig" on iOS < 26, checkmark on iOS 26+.
     Tries nav-bar first, then any button, across known labels. `\u{0010}Done` legacy included.
     */
    func galleryConfirmButton() -> XCUIElement? {
        let candidates = ["\u{0010}Done", "Done", "Fertig", "Choose", "Auswählen", "checkmark"]
        for label in candidates {
            let inNavBar = app.navigationBars.buttons[label].firstMatch
            if inNavBar.waitForExistence(timeout: 1) { return inNavBar }
        }
        for label in candidates {
            let anywhere = app.buttons[label].firstMatch
            if anywhere.waitForExistence(timeout: 1) { return anywhere }
        }
        return nil
    }

    func waitForAnalysisIfNeeded() {
        let analysisIndicators = [
            app.navigationBars[analysisScreenTitle],
            app.staticTexts[analysisLoadingText],
            app.staticTexts[analysisScreenTitle]
        ]
        if !analysisIndicators.contains(where: { $0.waitForExistence(timeout: 2) }) { return }
        /// Overlays the SDK presents on top of the analysis screen once processing is done:
        /// the transaction docs alert, or a bottom sheet (credit note warning, already-paid,
        /// due-date/schedule payment hint). Analysis is finished as soon as one is visible,
        /// even though the analysis navigation bar is still in the tree — waiting for it to
        /// disappear would deadlock against the overlay.
        let proceedTitles = ["Proceed anyway", "Proceed Anyway", "Trotzdem fortfahren"]
        let overlayProceedButton = app.buttons.matching(NSPredicate(format: "label IN %@", proceedTitles)).firstMatch
        for _ in 0..<30 {
            if analysisIndicators.allSatisfy({ !$0.exists }) { return }
            if transactionDocsScreen.onlyForThisTransaction.exists { return }
            if overlayProceedButton.waitForExistence(timeout: 1) { return }
        }
        XCTFail("Analysis screen did not disappear within timeout")
    }

    /**
     Copies all PDFs from `TestSamples/TestSamplesForBS/` into the tested app's `Documents/`
     folder, so the Files picker in UI tests can select them under
     "On My iPhone → GiniBankSDKExample".

     Xcode 15+ runs the test runner inside `XCTestDevices`, so `NSHomeDirectory()` returns
     `.../XCTestDevices/{UDID}/data/Containers/Data/Application/{runner-UUID}`. Going one
     level up reaches the shared `Application/` directory where all app containers for this
     test device live — including the tested app's container, which we identify by its
     `MCMMetadataIdentifier` plist entry.
     */
    private func copyFixturesToSimulator() {
        let fileManager = FileManager.default

        let applicationDir = URL(fileURLWithPath: NSHomeDirectory())
            .deletingLastPathComponent()
            .path

        guard let appFolders = try? fileManager.contentsOfDirectory(atPath: applicationDir) else { return }

        let fixturesURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()  // GiniBankSDKExampleUITests/
            .appendingPathComponent("TestSamples/TestSamplesForBS")

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

    func uploadLatestPhotoFromGallery(offset: Int = 0) {
        XCTAssertTrue(app.navigationBars[galleryTitle].waitForExistence(timeout: 10))
        app.tables.cells.firstMatch.tap()
        let imageCells = app.collectionViews.cells
        XCTAssertTrue(imageCells.firstMatch.waitForExistence(timeout: 10))
        let allCells = imageCells.allElementsBoundByIndex
        let targetIndex = allCells.count - 1 - offset
        guard targetIndex >= 0 else {
            XCTFail("No gallery image found at offset \(offset) — only \(allCells.count) photo(s) available.")
            return
        }
        allCells[targetIndex].tap()
        confirmGallerySelectionIfNeeded()
    }

    /**
     Confirms the gallery selection when the picker requires it.

     The confirm button title varies by iOS version and locale ("\u{0010}Done" on older
     pickers, plain "Done" on iOS 18, "Fertig"/"Add"/"Hinzufügen" elsewhere), and when
     multipage is disabled the SDK gallery advances straight to the review screen with
     no confirm step — so a missing button is only a failure if the review screen never
     appears either.
     */
    private func confirmGallerySelectionIfNeeded() {
        let titles = ["\u{0010}Done", "Done", "Fertig", "Add", "Hinzufügen"]
        let confirmButton = app.buttons.matching(NSPredicate(format: "label IN %@", titles)).firstMatch
        for _ in 0..<10 {
            if confirmButton.waitForExistence(timeout: 1), confirmButton.isHittable {
                confirmButton.tap()
                return
            }
            /// Multipage off — the picker already advanced to the review screen.
            if reviewScreen.processButton.exists { return }
        }
        XCTFail("Gallery confirm button not found and the review screen did not appear.")
    }
}

// MARK: - XCUIElement helpers

extension XCUIElement {
    /**
     Complement to `waitForExistence(timeout:)` — returns `true` if the element disappears in time.
     */
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let gonePredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gonePredicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
