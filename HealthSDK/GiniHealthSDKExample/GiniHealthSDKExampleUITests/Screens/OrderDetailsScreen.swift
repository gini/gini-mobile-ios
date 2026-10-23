//
//  OrderDetailsScreen.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Host-app Order Details screen (`OrderDetailViewController`).

 Pushed by `OrderListViewController` on row tap. Shows four editable fields
 (Recipient / IBAN / Amount / Purpose) plus two primary buttons: Create
 Payment Request and Pay. Tapping Pay starts the Health SDK's payment flow,
 which opens the Payment Review Screen as a bottom sheet — the Orders entry
 does NOT traverse the Payment Component Select-bank sheet used by the
 Invoices entry, so smoke journeys from here skip straight to Payment Review.

 Button titles are hardcoded English in `OrderDetailViewController.createButton`
 (no localisation, no accessibility identifier), so a plain label match is
 stable across the English-only host app builds the smoke suite runs on.
 */
final class OrderDetailsScreen {

    let app: XCUIApplication

    /**
     The Pay button at the bottom of the Order Details screen. Hardcoded
     English title "Pay"; no accessibility identifier is set upstream, so the
     lookup matches by label.
     */
    let payButton: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        self.payButton = app.buttons["Pay"].firstMatch
    }

    /**
     Taps the Pay button, opening the Payment Review Screen in a bottom
     sheet. Waits for the button to appear first so callers don't need a
     separate existence check.
     */
    func tapPay(timeout: TimeInterval = 10) {
        XCTAssertTrue(payButton.waitForExistence(timeout: timeout),
                      "Pay button not found on Order Details — screen may not have loaded.")
        payButton.tap()
    }
}
