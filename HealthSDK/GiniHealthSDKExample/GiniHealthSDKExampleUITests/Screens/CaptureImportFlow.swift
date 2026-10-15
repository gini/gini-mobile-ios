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
     Picks a PDF from the system Files picker by name. Adaptive wrapper:
     on BrowserStack the file is staged in `Custom_Files` by `uploadMedia`,
     and on the local simulator it is staged in
     `On My iPhone → GiniHealthSDKExample` by `copyFixturesToSimulator`.
     Checks for the BrowserStack folder first and falls back to the local
     path when it is absent, so the same call works in both environments.

     Mirrors Bank SDK's `MainScreen.tapFileFromBestAvailableSource`
     (`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Screens/MainScreen.swift`),
     which is the proven path for Files-picker import on BrowserStack.
     */
    func pickPDFFromFilesPicker(fileName: String) {
        let customFilesAny = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] 'Custom_Files'")).firstMatch

        /// When the picker opens on the Browse locations screen (not Recents),
        /// Custom_Files is already visible — tapping Browse again navigates to a
        /// different level and breaks detection.
        if !customFilesAny.waitForExistence(timeout: 3) {
            let browseButton = app.buttons["Browse"].firstMatch
            if browseButton.waitForExistence(timeout: 3) {
                browseButton.tap()
                /// Give the Files app time to render the Browse location list
                /// (BrowserStack can be slow).
                sleep(5)
            }
        }

        /// On iOS 15/16 the picker's Browse level shows only the locations list —
        /// Custom_Files lives under "On My iPhone" there instead of at the top level.
        if !customFilesAny.waitForExistence(timeout: 15) {
            let onMyPhoneButton = app.buttons["On My iPhone"].firstMatch
            let onMyPhoneText = app.staticTexts["On My iPhone"].firstMatch
            _ = onMyPhoneButton.waitForExistence(timeout: 3) || onMyPhoneText.waitForExistence(timeout: 2)
            if onMyPhoneButton.exists {
                onMyPhoneButton.tap()
            } else if onMyPhoneText.exists {
                onMyPhoneText.tap()
            }
        }

        if customFilesAny.waitForExistence(timeout: 5) {
            /// BrowserStack: Custom_Files is visible — navigate into it and pick the file.
            tapFileFromBSCustomFiles(fileName: fileName)
        } else {
            /// Local: fixture lives under On My iPhone → GiniHealthSDKExample.
            tapFileFromOnMyPhone(fileName: fileName)
        }
    }

    /**
     Navigates the document picker to BrowserStack's `Custom_Files` folder and
     taps the file. BrowserStack stages non-media files via `uploadMedia`
     under **Custom_Files**; when the picker launches scoped to the host app's
     container (iOS 17+ default), that folder appears as the only child inside
     `GiniHealthSDKExample`, so no `Browse` navigation is required to reach it.

     The staged filename carries a timestamp suffix
     (e.g. `testMedInvoice_1792076678`), so the file is matched with `CONTAINS[c]`.
     Tapping the file label only **selects** it (blue checkmark); the picker
     stays open until the **Open** / **Öffnen** nav-bar confirm button is tapped,
     which this helper does last.

     - Parameter fileName: File name without extension (matched with CONTAINS[c]).
     */
    private func tapFileFromBSCustomFiles(fileName: String) {
        let customFilesFolder = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] 'Custom_Files'")).firstMatch
        XCTAssertTrue(customFilesFolder.waitForExistence(timeout: 5),
                      "Custom_Files folder not found — ensure the file was uploaded via BrowserStack before running the test.")
        customFilesFolder.tap()

        let fileElement = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", fileName)).firstMatch
        XCTAssertTrue(fileElement.waitForExistence(timeout: 5),
                      "File '\(fileName)' not found in Custom_Files folder.")
        fileElement.tap()

        /// Selecting a file in Custom_Files puts a blue checkmark on it and
        /// surfaces the Open button in the nav bar; the picker only dismisses
        /// after that confirm. Mirrors the Open-button tap at the end of
        /// `tapFileFromOnMyPhone`.
        let openButton = app.buttons["Open"].firstMatch
        let openButtonDE = app.buttons["Öffnen"].firstMatch
        if openButton.waitForExistence(timeout: 3) {
            openButton.tap()
        } else if openButtonDE.waitForExistence(timeout: 1) {
            openButtonDE.tap()
        }
    }

    /**
     Navigates the document picker to the local `On My iPhone →
     GiniHealthSDKExample` folder (seeded by `copyFixturesToSimulator`) and
     taps the file. Falls back through sidebar discovery, swipe-to-find, and
     cell-first matching so a filename label tap doesn't open the file preview
     instead of selecting it. Confirms the selection by tapping the picker's
     **Open** / **Öffnen** button when it appears.

     - Parameter fileName: File name without extension (matched with CONTAINS[c]).
     */
    private func tapFileFromOnMyPhone(fileName: String) {
        let browseButton = app.buttons["Browse"].firstMatch
        if browseButton.waitForExistence(timeout: 3) {
            browseButton.tap()
        }

        let onMyPhoneButton = app.buttons["On My iPhone"].firstMatch
        let onMyPhoneText = app.staticTexts["On My iPhone"].firstMatch
        _ = onMyPhoneButton.waitForExistence(timeout: 5) || onMyPhoneText.waitForExistence(timeout: 5)
        if onMyPhoneButton.exists {
            onMyPhoneButton.tap()
        } else if onMyPhoneText.exists {
            onMyPhoneText.tap()
        }

        let appFolder = app.staticTexts["GiniHealthSDKExample"].firstMatch
        XCTAssertTrue(appFolder.waitForExistence(timeout: 5),
                      "GiniHealthSDKExample folder not found. Ensure PDFs exist in GiniHealthSDKExampleUITests/TestSamples/TestSamplesForBS.")
        appFolder.tap()

        sleep(1)

        /// Cells must be tried before staticTexts: tapping a staticText (the
        /// filename label) in the Files picker opens a full-screen preview and
        /// stays in Files app. Tapping the cell row properly selects the file
        /// for the document picker.
        func findFileElement() -> XCUIElement? {
            let byCell = app.cells.matching(NSPredicate(format: "label CONTAINS[c] %@", fileName)).firstMatch
            if byCell.exists { return byCell }
            let byStaticText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", fileName)).firstMatch
            if byStaticText.exists { return byStaticText }
            let byButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", fileName)).firstMatch
            if byButton.exists { return byButton }
            return nil
        }

        var swipeAttempts = 0
        while findFileElement() == nil && swipeAttempts < 5 {
            app.swipeUp()
            swipeAttempts += 1
            sleep(1)
        }

        guard let fileElement = findFileElement() else {
            XCTFail("File '\(fileName)' not found. Ensure it exists in GiniHealthSDKExampleUITests/TestSamples/TestSamplesForBS.")
            return
        }
        fileElement.tap()

        /// After selecting a file from a folder in "On My iPhone", the document
        /// picker shows an Open button in the navigation bar to confirm the
        /// selection. Tap it here so callers do not need a separate confirm step.
        let openButton = app.buttons["Open"].firstMatch
        let openButtonDE = app.buttons["Öffnen"].firstMatch
        if openButton.waitForExistence(timeout: 3) {
            openButton.tap()
        } else if openButtonDE.waitForExistence(timeout: 1) {
            openButtonDE.tap()
        }
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
