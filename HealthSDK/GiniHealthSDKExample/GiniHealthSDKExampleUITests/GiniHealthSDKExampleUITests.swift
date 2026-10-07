//
//  GiniHealthSDKExampleUITests.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Base class for every Health SDK XCUITest suite.

 Responsibilities:
 - Launches `GiniHealthSDKExample` with a clean state.
 - Instantiates every page object (`mainScreen`, `paymentReviewScreen`, …) so
   subclass tests read as plain English instructions.
 - Seeds the host app's `Documents/` directory with the fixtures used by the
   Files-import flows (local simulator only — on BrowserStack the Custom_Files
   folder is seeded by `uploadMedia` in `bs_run_*.sh`).
 - Attaches a last-screen screenshot on every test, failing or passing, so a
   BrowserStack session with no explicit assertion failure still carries visual
   evidence of what the device saw.
 */
class GiniHealthSDKExampleUITests: XCTestCase {

    var app: XCUIApplication!
    var mainScreen: MainScreen!
    var paymentReviewScreen: PaymentReviewScreen!
    var bankSelectionBottomSheet: BankSelectionBottomSheet!
    var captureImportFlow: CaptureImportFlow!
    var invoicesListScreen: InvoicesListScreen!

    override func setUpWithError() throws {
        /// Simulator skip is deliberate: the smoke suite relies on BrowserStack-staged media
        /// (Photos gallery, Custom_Files) that the local simulator has no equivalent for.
        /// Local developers use the host app directly rather than run the UI suite.
        #if targetEnvironment(simulator)
            throw XCTSkip("Health SDK UI tests only run on a device (BrowserStack).")
        #endif
        continueAfterFailure = false
        copyFixturesToSimulator()
        app = XCUIApplication()
        app.resetAuthorizationStatus(for: .camera)
        app.resetAuthorizationStatus(for: .photos)
        app.launchArguments = ["-StartFromCleanState", "YES"]
        app.launch()
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        mainScreen = MainScreen(app: app)
        paymentReviewScreen = PaymentReviewScreen(app: app)
        bankSelectionBottomSheet = BankSelectionBottomSheet(app: app)
        captureImportFlow = CaptureImportFlow(app: app, locale: locale)
        invoicesListScreen = InvoicesListScreen(app: app)
    }

    override func tearDownWithError() throws {
        #if !targetEnvironment(simulator)
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.lifetime = .deleteOnSuccess
            add(attachment)
            app.terminate()
        #endif
    }

    // MARK: - Fixture seeding

    /**
     Copies every PDF in `TestSamples/TestSamplesForBS/` into the running app's
     `Documents/` directory so the Files picker lists them under
     "On My iPhone → GiniHealthSDKExample".

     The test runner lives in a sibling container to the app, so we walk one level
     up from `NSHomeDirectory()` and identify the app's container by its
     `MCMMetadataIdentifier` plist entry. BrowserStack serves the same fixtures
     via `uploadMedia` → Custom_Files, so on BS this becomes a no-op (the PDFs
     reside in the OS-provided Custom_Files folder, not the app's Documents).
     */
    private func copyFixturesToSimulator() {
        let fileManager = FileManager.default
        let applicationDir = URL(fileURLWithPath: NSHomeDirectory())
            .deletingLastPathComponent().path
        guard let appFolders = try? fileManager.contentsOfDirectory(atPath: applicationDir) else { return }
        let fixturesURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("TestSamples/TestSamplesForBS")
        let pdfs = ((try? fileManager.contentsOfDirectory(at: fixturesURL,
                                                          includingPropertiesForKeys: nil,
                                                          options: .skipsHiddenFiles)) ?? [])
            .filter { $0.pathExtension == "pdf" }
        guard !pdfs.isEmpty else { return }
        for folder in appFolders {
            let metaPath = "\(applicationDir)/\(folder)/.com.apple.mobile_container_manager.metadata.plist"
            guard let metadata = NSDictionary(contentsOfFile: metaPath),
                  let bundleID = metadata["MCMMetadataIdentifier"] as? String,
                  bundleID == "net.gini.healthsdk.example" else { continue }
            let docsURL = URL(fileURLWithPath: "\(applicationDir)/\(folder)/Documents")
            try? fileManager.createDirectory(at: docsURL, withIntermediateDirectories: true)
            for pdf in pdfs {
                let dest = docsURL.appendingPathComponent(pdf.lastPathComponent)
                try? fileManager.copyItem(at: pdf, to: dest)
            }
            return
        }
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
