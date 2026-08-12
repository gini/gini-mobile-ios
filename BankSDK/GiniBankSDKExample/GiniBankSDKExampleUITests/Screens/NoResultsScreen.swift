//
//  NoResultsScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Page object for the No-Results screen shown when the CX analysis returns no extractions.
 The screen presents the same UI as the Error screen — "Enter manually" and "Back to camera".
 */
class NoResultsScreen {

    let app: XCUIApplication
    /// The primary button that navigates back to the camera screen.
    let backToCameraButton: XCUIElement
    /// The secondary button that lets the user enter payment data manually.
    let enterManuallyButton: XCUIElement

    init(app: XCUIApplication, locale: String) {
        self.app = app

        switch locale {
        case "en":
            /// The nav-bar back button has `value = "Camera Back"` — not a label — so match by value.
            backToCameraButton = app.buttons.matching(NSPredicate(format: "value == %@", "Camera Back")).firstMatch
            enterManuallyButton = app.buttons["Enter manually"]
        case "de":
            backToCameraButton = app.buttons.matching(NSPredicate(format: "value == %@", "Kamera Zurück")).firstMatch
            enterManuallyButton = app.buttons["Manuell ausfüllen"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }

    /**
     Waits for the No-Results screen to appear by checking for the "Enter manually" button.
     - Returns: `true` if the screen appeared within the timeout.
     */
    @discardableResult
    func waitForExistence(timeout: TimeInterval = 30) -> Bool {
        enterManuallyButton.waitForExistence(timeout: timeout)
    }
}
