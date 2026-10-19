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
 `PaymentReviewPaymentInformationView.swift` — the IDs are stable across
 locales. The close button and prefilled-data banner have no upstream
 identifier, so they are resolved per locale in init.
 */
final class PaymentReviewScreen {

    let app: XCUIApplication

    let recipientField: XCUIElement
    let ibanField: XCUIElement
    let amountField: XCUIElement
    let referenceField: XCUIElement
    let bankPickerButton: XCUIElement
    let payButton: XCUIElement

    /**
     Nav-bar close button on the Payment Review Screen. Resolved from
     `gini.health.close.button.accessibility.label` (EN "Close",
     DE "Schließen"; the DE informal variant uses the same string).
     */
    let closeButton: XCUIElement

    /**
     The extraction info banner ("Please check the pre-filled data.") shown
     when fields were populated by the extraction pipeline. Resolved from
     `gini.health.reviewscreen.infobar.message`; the DE formal and informal
     variants differ, so DE matches both via `label IN %@`.
     */
    let prefilledBanner: XCUIElement

    init(app: XCUIApplication, locale: String) {
        self.app = app
        self.recipientField = app.textFields["paymentReview.recipient"]
        self.ibanField = app.textFields["paymentReview.iban"]
        self.amountField = app.textFields["paymentReview.amount"]
        self.referenceField = app.textFields["paymentReview.reference"]
        self.bankPickerButton = app.buttons["paymentReview.bankPicker"]
        self.payButton = app.buttons["paymentReview.payButton"]

        switch locale {
        case "de":
            self.closeButton = app.buttons["Schließen"]
            let bannerCandidates = ["Bitte überprüfen Sie die vorausgefüllten Felder",
                                    "Bitte überprüfe die vorausgefüllten Felder"]
            self.prefilledBanner = app.staticTexts
                .matching(NSPredicate(format: "label IN %@", bannerCandidates))
                .firstMatch
        default:
            // Fall back to EN for any locale other than DE — unsupported
            // locales must not crash the test runner.
            self.closeButton = app.buttons["Close"]
            self.prefilledBanner = app.staticTexts["Please check the pre-filled data."]
        }
    }

    /**
     Reads the field's current value, falling back to its label when the
     SwiftUI TextField reports no value (iOS versions differ in which one
     carries the extracted text).
     */
    func value(of field: XCUIElement) -> String {
        if let text = field.value as? String, !text.isEmpty { return text }
        return field.label
    }
}
