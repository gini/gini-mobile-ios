//
//  PaymentComponentScreen.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Payment Component bottom sheet (`PaymentComponentView` in
 `GiniInternalPaymentSDK/PaymentComponents/`).

 Shown after Transfer directly on the Invoices List when no bank has been
 selected yet. Hosts a title ("Select your bank to pay"), a Select-bank
 button that opens the Bank Selection list, and a "More information" link.
 Picking a bank in the Bank Selection list dismisses this sheet and opens
 the full Payment Review Screen.
 */
final class PaymentComponentScreen {

    let app: XCUIApplication

    /**
     The Select-bank button (labelled "Your bank" / "Deine Bank" depending on
     locale). Addressed by the accessibility identifier set in
     `PaymentComponentView.updateButtonsViews()` so the test is locale-stable.
     */
    let selectBankButton: XCUIElement

    /**
     The "Continue to overview" primary button that appears only once a bank
     has been selected. Tapping it dismisses this sheet and opens the full
     Payment Review Screen.
     */
    let continueToOverviewButton: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        self.selectBankButton = app.buttons["paymentComponent.selectBank"]
        self.continueToOverviewButton = app.buttons["paymentComponent.continueToOverview"]
    }
}
