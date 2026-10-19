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

 No accessibility identifiers are set upstream — the screen is addressed by
 its localised strings. Strings resolved per locale in init, mirroring the
 Bank SDK example's page-object pattern.
 */
final class PaymentInfoScreen {

    let app: XCUIApplication

    /**
     Nav-bar title shown on the Payment Info screen. Resolved from
     `gini.health.paymentcomponent.payment.info.title.label` (EN "More
     information", DE "Mehr Informationen").
     */
    let navBarTitle: XCUIElement

    /**
     FAQ section header. Resolved from
     `gini.health.paymentcomponent.payment.info.questions.title.label`
     (EN "Frequently Asked Questions", DE "Häufig gestellte Fragen").
     */
    let faqTitle: XCUIElement

    /**
     Localised phrase for the inline **More Information** link on the
     Bank Selection sheet, used by `moreInformationTrigger`. Case-insensitive
     CONTAINS match tolerates the trailing period in the source string.
     */
    private let moreInformationPhrase: String

    init(app: XCUIApplication, locale: String) {
        self.app = app
        switch locale {
        case "de":
            self.navBarTitle = app.navigationBars.staticTexts["Mehr Informationen"]
            self.faqTitle = app.staticTexts["Häufig gestellte Fragen"]
            self.moreInformationPhrase = "Mehr Informationen"
        default:
            // Fall back to EN for any locale other than DE — unsupported
            // locales must not crash the test runner.
            self.navBarTitle = app.navigationBars.staticTexts["More information"]
            self.faqTitle = app.staticTexts["Frequently Asked Questions"]
            self.moreInformationPhrase = "More information"
        }
    }

    /**
     The inline **More Information** button hosted inside the Bank Selection
     sheet (`MoreInformationView` is itself a `UIButton`, so XCUITest exposes
     it under `app.buttons`). Matched by its `accessibilityLabel` with
     CONTAINS[c] to tolerate the trailing period on the source string.
     */
    var moreInformationTrigger: XCUIElement {
        app.buttons
            .matching(NSPredicate(format: "label CONTAINS[c] %@", moreInformationPhrase))
            .firstMatch
    }
}
