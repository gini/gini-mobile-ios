//
//  PaymentReviewScreen.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 SwiftUI Payment Review Screen (`PaymentReviewPaymentInformationView`).

 Fields are addressed by the accessibility identifiers set in
 `PaymentReviewPaymentInformationView.swift` — the IDs are stable across locales
 and survive future layout changes as long as the modifier stays on the field.
 */
final class PaymentReviewScreen {

    let app: XCUIApplication

    let recipientField: XCUIElement
    let ibanField: XCUIElement
    let amountField: XCUIElement
    let referenceField: XCUIElement
    let bankPickerButton: XCUIElement
    let payButton: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        self.recipientField = app.textFields["paymentReview.recipient"]
        self.ibanField = app.textFields["paymentReview.iban"]
        self.amountField = app.textFields["paymentReview.amount"]
        self.referenceField = app.textFields["paymentReview.reference"]
        self.bankPickerButton = app.buttons["paymentReview.bankPicker"]
        self.payButton = app.buttons["paymentReview.payButton"]
    }

    /**
     Reads the field's current value, falling back to its label when the SwiftUI
     TextField reports no value (iOS versions differ in which one carries the
     extracted text).
     */
    func value(of field: XCUIElement) -> String {
        if let text = field.value as? String, !text.isEmpty { return text }
        return field.label
    }
}
