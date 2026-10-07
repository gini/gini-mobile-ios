//
//  InvoicesListScreen.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Health SDK example app's `InvoicesListViewController`.

 Health routes a newly captured/imported document through the Invoices List
 before Payment Review opens — this intermediate step has no equivalent in
 the Bank SDK flow. Each row shows the invoice summary plus a "Transfer
 directly" button that jumps straight into the Payment Review Screen.

 The button title is hardcoded in `InvoiceTableViewCell.xib` and has no
 localization (verified in the Example app's `.strings` files), so a plain
 label match works across English and German device locales.
 */
final class InvoicesListScreen {

    let app: XCUIApplication

    /**
     Nav bar title shown on this screen — stable across locales because the
     example app does not localise the title.
     */
    let navBar: XCUIElement

    /**
     First "Transfer directly" button in the list — the one bound to the
     invoice we just added via the image-import flow (newest row).
     */
    let transferDirectlyButton: XCUIElement

    /**
     Nav-bar "↑ Invoices" button on the right side. On a fresh install the
     Invoices List is empty; tapping this button triggers the host app's
     `HardcodedInvoicesController` to upload the bundled sample documents
     to the Gini API, which then appear as rows once extraction completes.
     Addressed by the accessibility identifier set in
     `InvoicesListViewController.setupNavigationBar` so the test is robust
     to the ↑ Unicode glyph and locale changes.
     */
    let uploadInvoicesButton: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        self.navBar = app.navigationBars["Invoices List"]
        self.transferDirectlyButton = app.buttons["Transfer directly"].firstMatch
        self.uploadInvoicesButton = app.buttons["invoicesList.uploadInvoices"]
    }

    /**
     Ensures the Invoices List carries at least one row with a Transfer
     directly button. If the list is empty, taps ↑ Invoices to seed the
     hardcoded sample documents, then waits for the first row to appear.
     Idempotent: if a row is already visible the upload tap is skipped.
     */
    func seedIfEmpty(uploadTimeout: TimeInterval = 60) {
        if transferDirectlyButton.waitForExistence(timeout: 10) { return }
        XCTAssertTrue(uploadInvoicesButton.waitForExistence(timeout: 5),
                      "↑ Invoices nav button not found on the empty Invoices List — host app may have changed the title string.")
        uploadInvoicesButton.tap()
        XCTAssertTrue(transferDirectlyButton.waitForExistence(timeout: uploadTimeout),
                      "Invoices did not populate within \(Int(uploadTimeout)) s after tapping ↑ Invoices — HardcodedInvoicesController upload or extraction may have failed.")
    }
}
