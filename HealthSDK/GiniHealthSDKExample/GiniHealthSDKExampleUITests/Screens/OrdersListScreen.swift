//
//  OrdersListScreen.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Host-app Orders list screen.

 Different UI from `InvoicesListScreen`: rows carry no per-row Transfer
 directly button. The user taps a row directly to kick off the Payment
 Component flow. Nav bar still exposes an upload button for the empty-state
 seed path.
 */
final class OrdersListScreen {

    let app: XCUIApplication

    /**
     First row of the orders table — tapping it is equivalent to tapping
     Transfer directly on an invoice. Falls back to the first cell matching
     a table on screen so the lookup works regardless of nav title or
     table-view identifier (not currently set in the host app).
     */
    var firstRow: XCUIElement {
        app.tables.firstMatch.cells.firstMatch
    }

    init(app: XCUIApplication) {
        self.app = app
    }

    /**
     Waits for the orders table to have at least one row. On empty tables,
     the host app's seeding button on the nav bar can be tapped by callers
     (same ↑ Invoices style upload action) — not wired here because Orders
     flow may need a different seed trigger; add when a fresh-run empty
     state is observed.
     */
    func waitForFirstRow(timeout: TimeInterval = 60) -> Bool {
        firstRow.waitForExistence(timeout: timeout)
    }
}
