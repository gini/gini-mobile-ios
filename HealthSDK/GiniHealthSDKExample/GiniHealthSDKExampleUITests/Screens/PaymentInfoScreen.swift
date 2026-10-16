//
//  PaymentInfoScreen.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Payment Info bottom sheet (`PaymentInfoViewController` in
 `GiniInternalPaymentSDK/PaymentInfo/`).

 Opens from the Bank Selection sheet (`BanksBottomView`) when the user taps
 the inline **More Information** link rendered by `MoreInformationView`.
 The view controller is presented inside a `UINavigationController`, so
 its nav bar title acts as the identifier for the screen.

 No accessibility identifiers are set upstream — the screen is addressed
 by its localised strings:
 - Nav title: `gini.health.paymentcomponent.payment.info.title.label`
   (EN "More information", DE "Weitere Informationen").
 - FAQ section title: `gini.health.paymentcomponent.payment.info.questions.title.label`
   (EN "Frequently Asked Questions", DE "Häufig gestellte Fragen").

 The More Information trigger is a `UIButton` with its `accessibilityLabel`
 taken from the attributed string
 `gini.health.paymentcomponent.more.information.underlined.part` — matched
 case-insensitive-contains to tolerate the trailing period and the DE/EN
 variants.
 */
final class PaymentInfoScreen {

    let app: XCUIApplication

    /**
     Nav-bar title shown on the Payment Info screen. The nav title lives in
     the host `UINavigationController` set by `BanksBottomView.didTapOnMoreInformation`,
     with its `title` property driven by `viewModel.strings.titleText`.
     */
    let navBarTitle: XCUIElement

    /**
     FAQ section header rendered on the Payment Info screen. Stable across
     presentations because it originates from a non-dynamic SDK string.
     */
    let faqTitle: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        self.navBarTitle = app.navigationBars.staticTexts
            .matching(NSPredicate(format: "label IN %@", ["More information", "Weitere Informationen"]))
            .firstMatch
        self.faqTitle = app.staticTexts
            .matching(NSPredicate(format: "label IN %@", ["Frequently Asked Questions", "Häufig gestellte Fragen"]))
            .firstMatch
    }

    /**
     The inline **More Information** button hosted inside the Bank Selection
     sheet (`MoreInformationView` is itself a `UIButton`, so XCUITest exposes
     it under `app.buttons`). Matched by its `accessibilityLabel` with
     CONTAINS[c] to tolerate the trailing period present in the EN string
     and the DE variant.
     */
    var moreInformationTrigger: XCUIElement {
        app.buttons
            .matching(NSPredicate(format: "label CONTAINS[c] 'More information' OR label CONTAINS[c] 'Weitere Informationen'"))
            .firstMatch
    }
}
