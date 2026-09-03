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

    /**
     Returns the extraction row cell whose title label matches the raw extraction name
     (the demo app renders `extraction.name` verbatim as the row title, e.g. `iban`,
     `amountToPay`, `paymentRecipient`). Scrolls the table until the row is on screen,
     because off-screen table view cells do not exist for XCUITest queries.
     - Parameters:
       - name: Raw extraction name used as the row title.
     - Returns: The matching cell.
     */
    func extractionRow(named name: String) -> XCUIElement {
        let cell = app.cells.containing(.staticText, identifier: name).firstMatch
        var swipeCount = 0
        while !cell.exists && swipeCount < 5 {
            app.swipeUp()
            swipeCount += 1
        }
        XCTAssertTrue(cell.waitForExistence(timeout: 5),
                      "Extraction row '\(name)' not found in the Transfer Summary screen.")
        return cell
    }

    /**
     Reads the editable value of an extraction row.
     - Parameters:
       - name: Raw extraction name used as the row title.
     - Returns: The text field content, or an empty string when the field is empty.
     */
    func extractionValue(named name: String) -> String {
        let field = extractionRow(named: name).textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5),
                      "Value text field for extraction '\(name)' not found.")
        return (field.value as? String) ?? ""
    }
}
