//
//  CaptureImportFlow.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Thin page-object wrapper over the Gini Capture SDK's import flow — the common
 bridge between the host app's `startWithGiniCapture` entry and the SDK's
 Payment Review Screen. Health and Bank both consume `GiniCaptureSDK`, so this
 mirrors Bank's `CaptureScreen` / `OnboardingScreen` but only exposes what the
 Health smoke journeys actually traverse.

 Queries are text-based (localised to English/German) because CaptureSDK's UI
 does not expose stable accessibility identifiers on these controls. Add
 identifiers upstream when GCS gets a dedicated QA pass; until then text
 matching stays the pragmatic path.
 */
final class CaptureImportFlow {

    let app: XCUIApplication
    let locale: String

    init(app: XCUIApplication, locale: String) {
        self.app = app
        self.locale = locale
    }

    private var getStartedTitles: [String] {
        ["Get Started", "Jetzt starten", "Loslegen"]
    }

    private var importButtonTitles: [String] {
        ["Files", "Dateien", "Import", "Importieren"]
    }

    private var photoLibraryTitles: [String] {
        ["Photo Library", "Photos", "Fotos", "Fotomediathek", "Choose Photo"]
    }

    private var processButtonTitles: [String] {
        ["Process", "Next", "Weiter", "Verarbeiten"]
    }

    /**
     Skips the onboarding carousel if it is presented. CaptureSDK versions
     vary — some ship no onboarding at all for returning users — so a missing
     "Get Started" button is not a failure.
     */
    func skipOnboardingIfPresented(timeout: TimeInterval = 5) {
        let getStarted = app.buttons.matching(NSPredicate(format: "label IN %@", getStartedTitles)).firstMatch
        if getStarted.waitForExistence(timeout: timeout), getStarted.isHittable {
            getStarted.tap()
        }
    }

    /**
     Taps the Files/Import entry and then the Photo Library option so the
     system photo picker opens. Expects the camera screen to already be visible.
     */
    func tapImportThenPhotoLibrary() {
        let importButton = app.buttons.matching(NSPredicate(format: "label IN %@", importButtonTitles)).firstMatch
        XCTAssertTrue(importButton.waitForExistence(timeout: 10),
                      "Import entry not found on the Capture screen.")
        importButton.tap()
        let photoLibrary = app.buttons.matching(NSPredicate(format: "label IN %@", photoLibraryTitles)).firstMatch
        XCTAssertTrue(photoLibrary.waitForExistence(timeout: 10),
                      "Photo Library option not found in the import sheet.")
        photoLibrary.tap()
    }

    /**
     Taps the most recently added gallery image.

     The Albums navigation is a two-step process on iOS 15+ — tap the first
     album entry, then the last image in the collection. Older iOS variants
     may skip the album picker; in that case the image grid is already visible
     and the fallback-collection-view path handles it.
     */
    func pickLatestPhoto() {
        let albumsTable = app.tables.firstMatch
        if albumsTable.waitForExistence(timeout: 5) {
            albumsTable.cells.firstMatch.tap()
        }
        let imageGrid = app.collectionViews.firstMatch
        XCTAssertTrue(imageGrid.waitForExistence(timeout: 10),
                      "Photo picker image grid did not appear.")
        let cells = imageGrid.cells.allElementsBoundByIndex
        guard let last = cells.last else {
            XCTFail("Photo picker is empty — the gallery was not seeded.")
            return
        }
        last.tap()
    }

    /**
     Taps the Process/Next button on the review screen that CaptureSDK
     presents after a successful import, kicking off extraction.
     */
    func tapProcessOnReview() {
        let process = app.buttons.matching(NSPredicate(format: "label IN %@", processButtonTitles)).firstMatch
        XCTAssertTrue(process.waitForExistence(timeout: 10),
                      "Process button not found on CaptureSDK's review screen.")
        process.tap()
    }
}
