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

    private var skipButtonTitles: [String] {
        /// CaptureSDK's onboarding puts a Skip button in the top-right of the nav bar
        /// (per Bank SDK's OnboardingScreen page object).
        ["Skip", "Überspringen"]
    }

    private var filesButtonTitles: [String] {
        /// First tap on the camera screen — opens the import sheet.
        ["Files", "Dateien"]
    }

    private var uploadPhotoButtonTitles: [String] {
        /// Entry inside the import sheet that opens the system photo picker.
        ["Upload photo", "Fotos hochladen"]
    }

    private var processButtonTitles: [String] {
        ["Process", "Next", "Weiter", "Verarbeiten"]
    }

    /**
     Dismisses the onboarding carousel by tapping the Skip button in the nav bar.
     CaptureSDK versions vary — some ship no onboarding at all for returning users —
     so a missing Skip button within `timeout` is not a failure.
     */
    func skipOnboardingIfPresented(timeout: TimeInterval = 5) {
        let skip = app.navigationBars.buttons.matching(NSPredicate(format: "label IN %@", skipButtonTitles)).firstMatch
        if skip.waitForExistence(timeout: timeout), skip.isHittable {
            skip.tap()
        }
    }

    /**
     Opens the system photo picker from the camera screen:
     Files button → Upload photo. Expects the camera screen to be visible.

     CaptureSDK exposes the Files button through `BottomLabelButton` with
     `accessibilityValue` set to the localised label — no `accessibilityLabel`
     and no `accessibilityIdentifier`. XCUITest's `label` query misses the
     control entirely, so the predicate below also matches on `value`.
     */
    func tapImportThenPhotoLibrary() {
        let filesButton = app.buttons
            .matching(NSPredicate(format: "(label IN %@) OR (value IN %@)",
                                  filesButtonTitles, filesButtonTitles))
            .firstMatch
        XCTAssertTrue(filesButton.waitForExistence(timeout: 10),
                      "Files entry not found on the Capture screen.")
        filesButton.tap()
        let uploadPhoto = app.buttons
            .matching(NSPredicate(format: "(label IN %@) OR (value IN %@)",
                                  uploadPhotoButtonTitles, uploadPhotoButtonTitles))
            .firstMatch
        XCTAssertTrue(uploadPhoto.waitForExistence(timeout: 10),
                      "Upload photo entry not found in the import sheet.")
        uploadPhoto.tap()
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
