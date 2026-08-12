//
//  CXExtractionScreen.swift
//  GiniBankSDKExampleUITests
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Page object for the CX extraction results screen shown after cross-border payment
 document analysis completes.

 The screen presents individual extraction fields as labelled text fields whose
 accessibility identifier equals the field name (e.g. `"creditorName"`,
 `"creditorIBAN"`). A navigation-bar "Done" button submits the result and
 returns to the main screen.
 */
class CXExtractionScreen {

    let app: XCUIApplication

    /// Navigation bar "Done" button that submits the extraction result and closes the SDK.
    var doneButton: XCUIElement {
        app.navigationBars.buttons["Done"]
    }

    /**
     The complete list of extraction field accessibility identifiers produced by the
     CX (cross-border) backend.
     */
    static let allFieldIdentifiers: [String] = [
        "creditorName",
        "creditorIBAN",
        "creditorAccountNumber",
        "creditorStreet",
        "creditorCity",
        "creditorPostalCode",
        "creditorCountry",
        "creditorAgentBIC",
        "creditorAgentName",
        "creditorAgentStreet",
        "creditorAgentCity",
        "currency",
        "instructedAmount",
        "remittanceInformation",
        "chargeBearer",
        "purposeCode",
        "instructionPriority",
        "bankInstructionCode",
        "economicCode",
        "creditorNationalId",
        "creditorAgentABA",
        "creditorAgentTransitNumber",
        "creditorAgentCNAPS",
        "creditorAgentSortCode",
        "creditorAgentBOKCode",
        "creditorAgentISPB",
        "creditorAgentBSB",
        "creditorAgentIFSC",
        "creditorAgentBankBranchCode",
        "creditorAgentIBGCode",
        "creditorAgentThaiCode",
        "creditorAgentBranchCode",
        "creditorAgentNZCode",
        "creditorCLABE"
    ]

    /**
     The subset of fields that are expected to carry non-empty values for a successful
     CX extraction. At least one of these must be populated for a test to pass.
     */
    static let keyFieldIdentifiers: [String] = [
        "creditorIBAN",
        "creditorAccountNumber",
        "creditorName",
        "creditorAgentBIC"
    ]

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Waiting

    /**
     Waits for the CX extraction screen to become visible by polling for the "Done"
     navigation button.
     - Parameters:
       - timeout: Maximum wait time in seconds.
     - Returns: `true` if the screen appeared within the timeout; otherwise `false`.
     */
    @discardableResult
    func waitForExistence(timeout: TimeInterval = 10) -> Bool {
        doneButton.waitForExistence(timeout: timeout)
    }

    // MARK: - Field verification

    /**
     Scans every field in `allFieldIdentifiers` and categorises each as found or not found.
     Prints a structured report to the test log.
     - Returns: A tuple containing the sorted arrays of found and not-found identifiers.
     */
    @discardableResult
    func verifyExtractionFields() -> (found: [String], notFound: [String]) {
        var results: [String: String] = [:]

        for field in Self.allFieldIdentifiers {
            let textField = app.textFields[field]
            let staticText = app.staticTexts[field]

            if textField.exists {
                results[field] = textField.value as? String ?? "present (no value)"
            } else if staticText.exists {
                results[field] = staticText.label.isEmpty ? "present (empty)" : staticText.label
            } else {
                results[field] = "not found"
            }
        }

        let found = results.filter { $0.value != "not found" }.keys.sorted()
        let notFound = results.filter { $0.value == "not found" }.keys.sorted()

        return (found: Array(found), notFound: Array(notFound))
    }

    /**
     Checks whether at least one key payment field carries a non-empty extracted value.
     Prints a per-field report to the test log.
     - Returns: `true` if at least one key field has a value; otherwise `false`.
     */
    @discardableResult
    func verifyKeyFieldsHaveValues() -> Bool {
        var anyHasValue = false

        for field in Self.keyFieldIdentifiers {
            let textField = app.textFields[field]
            let staticText = app.staticTexts[field]
            var value: String?

            if textField.exists {
                value = textField.value as? String
            } else if staticText.exists {
                value = staticText.label.isEmpty ? nil : staticText.label
            }

            let isPopulated = value.map { !$0.isEmpty && $0 != "not found" && $0 != "present (empty)" && $0 != "present (no value)" } ?? false
            if isPopulated {
                anyHasValue = true
            }
        }

        return anyHasValue
    }

    // MARK: - Actions

    /**
     Taps the "Done" navigation button to submit the extraction result and close the SDK.
     Fails the test if the button is not present within the default timeout.
     */
    func tapDoneButton() {
        XCTAssertTrue(
            doneButton.waitForExistence(timeout: 10),
            "Done button should be visible on the CX extraction screen."
        )
        doneButton.tap()
    }
}
