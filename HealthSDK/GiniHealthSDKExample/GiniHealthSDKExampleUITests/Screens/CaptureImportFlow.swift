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

    private var uploadFilesButtonTitles: [String] {
        /// Entry inside the import sheet that opens the system Files picker.
        /// Localised in CaptureSDK as `ginicapture.camera.popupOptionFiles`
        /// ("Upload files" / "Dokument hochladen").
        ["Upload files", "Dokument hochladen"]
    }

    private var processButtonTitles: [String] {
        ["Process", "Next", "Weiter", "Verarbeiten"]
    }

    private var galleryNavTitles: [String] {
        /// Photos picker's root nav title — the Albums list screen.
        ["Albums", "Alben"]
    }

    private var confirmGallerySelectionTitles: [String] {
        /// Picker confirm button varies by iOS version and locale.
        /// `\u{0010}Done` is the legacy iOS < 18 glyph; `Done` is iOS 18+.
        /// Multipage-off builds advance straight to the review screen with
        /// no confirm step — handled in `pickLatestPhoto`.
        ["\u{0010}Done", "Done", "Fertig", "Add", "Hinzufügen"]
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
     Taps the most recently added gallery image. Mirrors Bank's
     `uploadLatestPhotoFromGallery` so Health follows the same proven pattern.

     Steps:
     1. Wait for the Photos picker's **Albums** nav bar.
     2. Tap the first table row (opens the first album, usually Recents).
     3. Wait for the image collection to load; tap the LAST cell
        (most recently added — on BrowserStack this is `testMedInvoice.png`
        uploaded via `uploadMedia`).
     4. Confirm the selection with Done/Fertig/Add. If multipage is disabled
        the picker already advanced to the review screen — the confirm step
        is skipped in that case.
     */
    func pickLatestPhoto() {
        let albumsNavBar = app.navigationBars
            .matching(NSPredicate(format: "identifier IN %@ OR title IN %@",
                                  galleryNavTitles, galleryNavTitles))
            .firstMatch
        XCTAssertTrue(albumsNavBar.waitForExistence(timeout: 10),
                      "Photos picker Albums screen did not appear.")
        app.tables.cells.firstMatch.tap()

        let imageGrid = app.collectionViews.firstMatch
        XCTAssertTrue(imageGrid.cells.firstMatch.waitForExistence(timeout: 10),
                      "Photo picker image grid did not appear.")
        let cells = imageGrid.cells.allElementsBoundByIndex
        guard let last = cells.last else {
            XCTFail("Photo picker is empty — the gallery was not seeded.")
            return
        }
        last.tap()

        confirmGallerySelectionIfNeeded()
    }

    /**
     Confirms the gallery selection by tapping Done / Fertig / Add — iOS and
     locale variants are tried in sequence. Multipage-off builds already
     advanced to CaptureSDK's review screen, in which case the Process button
     exists and the confirm step is a no-op. Fails only if neither signal
     appears within 10 polling cycles.
     */
    private func confirmGallerySelectionIfNeeded() {
        let confirmButton = app.buttons
            .matching(NSPredicate(format: "label IN %@", confirmGallerySelectionTitles))
            .firstMatch
        let processButton = app.buttons
            .matching(NSPredicate(format: "(label IN %@) OR (value IN %@)",
                                  processButtonTitles, processButtonTitles))
            .firstMatch
        for _ in 0..<10 {
            if confirmButton.waitForExistence(timeout: 1), confirmButton.isHittable {
                confirmButton.tap()
                return
            }
            /// Multipage-off: the picker already advanced to the review screen.
            if processButton.exists { return }
        }
        XCTFail("Gallery confirm button not found and the review screen did not appear.")
    }

    /**
     Opens the system Files picker from the camera screen:
     Files button → Upload files. Expects the camera screen to be visible.
     Mirrors `tapImportThenPhotoLibrary` but routes to the Files picker
     instead of the Photos picker.
     */
    func tapImportThenFiles() {
        let filesButton = app.buttons
            .matching(NSPredicate(format: "(label IN %@) OR (value IN %@)",
                                  filesButtonTitles, filesButtonTitles))
            .firstMatch
        XCTAssertTrue(filesButton.waitForExistence(timeout: 10),
                      "Files entry not found on the Capture screen.")
        filesButton.tap()
        let uploadFiles = app.buttons
            .matching(NSPredicate(format: "(label IN %@) OR (value IN %@)",
                                  uploadFilesButtonTitles, uploadFilesButtonTitles))
            .firstMatch
        XCTAssertTrue(uploadFiles.waitForExistence(timeout: 10),
                      "Upload files entry not found in the import sheet.")
        uploadFiles.tap()
    }

    /**
     Picks a PDF from the system Files picker by name. Works on both
     BrowserStack (fixture staged in Custom_Files) and the simulator
     (fixture staged in the app's Documents folder by
     `copyFixturesToSimulator`). Looks for the file in the current view;
     falls back to tapping "On My iPhone" if the file is not immediately
     visible.
     */
    func pickPDFFromFilesPicker(fileName: String) {
        let fileCell = app.staticTexts[fileName].firstMatch
        if !fileCell.waitForExistence(timeout: 5) {
            /// Narrow the Files picker to the local on-device location.
            let onMyPhone = app.buttons["On My iPhone"].firstMatch
            if onMyPhone.waitForExistence(timeout: 3), onMyPhone.isHittable {
                onMyPhone.tap()
            }
        }
        XCTAssertTrue(fileCell.waitForExistence(timeout: 10),
                      "File \"\(fileName)\" not found in the Files picker — fixture may not be staged.")
        fileCell.tap()
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
