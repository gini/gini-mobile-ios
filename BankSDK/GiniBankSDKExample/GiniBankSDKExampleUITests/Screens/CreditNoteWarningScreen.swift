//
//  CreditNoteWarningScreen.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Page object for the "Credit Note Warning" bottom sheet
 (`CreditNoteWarningViewController` in GiniCaptureSDK).

 The sheet appears after analysis when the backend classifies the document as
 a credit note (`businessDocType == "creditnote"`) and both the SDK flag
 `creditNoteHintEnabled` and the backend client-configuration flag are enabled.

 The SDK views carry no accessibility identifiers yet, so elements are matched
 by their localized titles (see `ginicapture.creditNote.warning.*` keys in
 GiniCaptureSDK's Localizable.strings). Migrate to identifiers once the SDK
 exposes them.
 */
class CreditNoteWarningScreen {

    let app: XCUIApplication
    let title: XCUIElement
    let cancelTransferButton: XCUIElement
    let proceedAnywayButton: XCUIElement

    init(app: XCUIApplication,
         locale: String) {
        self.app = app

        switch locale {
        case "en":
            title = app.staticTexts["Credit Note Warning"]
            cancelTransferButton = app.buttons["Cancel transfer"]
            proceedAnywayButton = app.buttons["Proceed anyway"]

        case "de":
            title = app.staticTexts["Achtung: Gutschrift hochgeladen"]
            cancelTransferButton = app.buttons["Überweisung abbrechen"]
            proceedAnywayButton = app.buttons["Trotzdem fortfahren"]

        default:
            fatalError("Locale \(locale) is not supported")
        }
    }

    /**
     Waits for the warning sheet to be fully presented — title and both buttons.
     - Parameter timeout: Maximum time to wait for the sheet to appear.
     - Returns: `true` when the title and both buttons exist.
     */
    func waitForDialog(timeout: TimeInterval = 10) -> Bool {
        return title.waitForExistence(timeout: timeout)
            && cancelTransferButton.waitForExistence(timeout: 2)
            && proceedAnywayButton.waitForExistence(timeout: 2)
    }

    /**
     Taps the dimmed area above the bottom sheet — outside both buttons.
     Used to verify the sheet cannot be dismissed by tapping outside.

     Note: `InfoBottomSheetViewController` forces a full-screen sheet on small/non-notch
     devices and at accessibility text sizes; there the tap lands on the sheet's own
     header area instead of the dimmed background, which is equally non-dismissing but
     does not exercise the outside-tap path. Run on the standard device matrix for a
     meaningful check.
     */
    func tapOutsideDialog() {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
    }
}
