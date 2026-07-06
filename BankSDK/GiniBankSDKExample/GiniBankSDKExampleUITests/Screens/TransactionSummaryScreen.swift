//
//  TransactionSummaryScreen.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Page object for the Transfer Summary / Transaction Summary screen shown by the demo app
 after document analysis completes.
 */
class TransactionSummaryScreen {

    let app: XCUIApplication
    /// Navigation bar "Done" button that submits the transfer and closes the SDK.
    let doneButton: XCUIElement
    /// Footer button that triggers scanning another document.
    let testNewDocumentButton: XCUIElement
    /// The first extraction cell in the table view.
    let firstExtractionCell: XCUIElement

    init(app: XCUIApplication, locale: String) {
        self.app = app

        switch locale {
        case "en":
            doneButton = app.navigationBars.buttons["Done"]
            testNewDocumentButton = app.buttons["Test a new document"]
        case "de":
            doneButton = app.navigationBars.buttons["Fertig"]
            testNewDocumentButton = app.buttons["Anderes Dokument testen"]
        default:
            fatalError("Locale \(locale) is not supported")
        }

        firstExtractionCell = app.cells.firstMatch
    }

    /**
     Asserts that at least one extraction row is visible in the table.
     */
    func assertExtractionsAreDisplayed() {
        XCTAssertTrue(firstExtractionCell.waitForExistence(timeout: 15),
                      "Expected at least one extraction row in the Transfer Summary screen.")
    }

    /**
     Taps the "Done" navigation button to submit the transfer and close the SDK.
     */
    func tapDoneButton() {
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10))
        doneButton.tap()
    }
}
