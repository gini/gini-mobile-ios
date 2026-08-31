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
    /// Only present for camera-captured documents — file imports have nothing to retake.
    let retakeImagesButton: XCUIElement
    /// The nav-bar back button (matched by value; the SDK sets it as the button's value).
    let navBackButton: XCUIElement
    /// The secondary button that lets the user enter payment data manually.
    let enterManuallyButton: XCUIElement

    init(app: XCUIApplication, locale: String) {
        self.app = app

        switch locale {
        case "en":
            retakeImagesButton = app.buttons["Retake images"]
            navBackButton = app.buttons.matching(NSPredicate(format: "value == %@", "Camera Back")).firstMatch
            enterManuallyButton = app.buttons["Enter manually"]
        case "de":
            retakeImagesButton = app.buttons["Foto wiederholen"]
            navBackButton = app.buttons.matching(NSPredicate(format: "value == %@", "Kamera Zurück")).firstMatch
            enterManuallyButton = app.buttons["Manuell ausfüllen"]
        default:
            fatalError("Locale \(locale) is not supported")
        }
    }

    /**
     Navigates back to the camera from the No-Results screen.
     Prefers the "Retake images" button (camera-captured documents); file imports have
     no retake button, so it falls back to the nav-bar back button — by value match
     first, then the leading nav-bar button.
     */
    func goBackToCamera() {
        if retakeImagesButton.waitForExistence(timeout: 3), retakeImagesButton.isHittable {
            retakeImagesButton.tap()
            return
        }
        if navBackButton.waitForExistence(timeout: 3), navBackButton.isHittable {
            navBackButton.tap()
            return
        }
        let leadingNavButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(leadingNavButton.waitForExistence(timeout: 3),
                      "No way back to the camera found on the No-Results screen.")
        leadingNavButton.tap()
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
