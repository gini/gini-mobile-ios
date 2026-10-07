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

    init(app: XCUIApplication) {
        self.app = app
        self.navBar = app.navigationBars["Invoices List"]
        self.transferDirectlyButton = app.buttons["Transfer directly"].firstMatch
    }
}
