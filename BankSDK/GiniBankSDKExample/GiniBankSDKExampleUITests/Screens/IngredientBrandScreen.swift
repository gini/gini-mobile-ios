//
//  IngredientBrandScreen.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import XCTest

/**
 Page Object for the Ingredient Brand elements shown on the Analysis screen
 (`AnalysisViewController` in `GiniCaptureSDK`) when `ingredientBrandScreens`
 contains `"Analysis"`. Element lookups go through `accessibilityIdentifier`,
 so the object is locale-independent.
 */
class IngredientBrandScreen {

    let app: XCUIApplication

    /**
     The default `UIActivityIndicatorView` shown when the ingredient-brand
     flag is off.
     */
    let defaultLoadingIndicator: XCUIElement

    /**
     The branded Gini loading indicator shown when the flag is on.
     */
    let poweredByGiniLoadingIndicator: XCUIElement

    /**
     The "Powered by Gini" badge pinned to the bottom of the Analysis
     screen when the flag is on.
     */
    let poweredByGiniBadge: XCUIElement

    /**
     Integrator-injected custom loading indicator (UI-test stand-in).
     */
    let customLoadingIndicator: XCUIElement

    /**
     Marker attached to the key window, flipped visible when
     `didCancelCapturing` fires from `ScreenAPICoordinator`.
     */
    let didCancelCapturingMarker: XCUIElement

    /**
     Marker attached to the key window, flipped visible when
     `giniCaptureAnalysisDidFinishWith(result:)` fires from
     `ScreenAPICoordinator`.
     */
    let giniCaptureAnalysisDidFinishMarker: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        defaultLoadingIndicator = app.activityIndicators[
            IngredientBrandScreenAccessibilityIdentifiers.defaultLoadingIndicator
        ]
        poweredByGiniLoadingIndicator = app.images[
            IngredientBrandScreenAccessibilityIdentifiers.IngredientBrand.poweredByGiniLoadingIndicator
        ]
        poweredByGiniBadge = app.images[
            IngredientBrandScreenAccessibilityIdentifiers.IngredientBrand.poweredByGiniBadge
        ]
        customLoadingIndicator = app.otherElements[
            IngredientBrandScreenAccessibilityIdentifiers.customLoadingIndicator
        ]
        didCancelCapturingMarker = app.otherElements[
            IngredientBrandScreenAccessibilityIdentifiers.DelegateObservers.didCancelCapturing
        ]
        giniCaptureAnalysisDidFinishMarker = app.otherElements[
            IngredientBrandScreenAccessibilityIdentifiers.DelegateObservers.giniCaptureAnalysisDidFinish
        ]
    }

    /**
     Waits for the branded loading indicator to appear.
     */
    @discardableResult
    func waitForBrandedLoadingIndicator(timeout: TimeInterval = 15) -> Bool {
        poweredByGiniLoadingIndicator.waitForExistence(timeout: timeout)
    }

    /**
     Waits for the "Powered by Gini" badge to appear.
     */
    @discardableResult
    func waitForBadge(timeout: TimeInterval = 15) -> Bool {
        poweredByGiniBadge.waitForExistence(timeout: timeout)
    }

    /**
     Waits for the default (non-branded) loading indicator to appear.
     */
    @discardableResult
    func waitForDefaultLoadingIndicator(timeout: TimeInterval = 15) -> Bool {
        defaultLoadingIndicator.waitForExistence(timeout: timeout)
    }

    /**
     Waits for the integrator-injected custom loading indicator to appear.
     */
    @discardableResult
    func waitForCustomLoadingIndicator(timeout: TimeInterval = 15) -> Bool {
        customLoadingIndicator.waitForExistence(timeout: timeout)
    }

    // MARK: - Locale-dependent probes for education view + capture-suggestions banner

    /**
     Locale-dependent probe for the education view. Matches the localized
     intro static text (`ginicapture.analysis.education.loading.intro`) — see
     `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources`. Adding a
     locale means adding a case here.
     */
    func educationIntroStaticText(locale: String) -> XCUIElement {
        let text: String
        switch locale {
        case "de": text = "Falls Sie es nicht wussten..."
        default:   text = "In case you didn\u{2019}t know..."
        }
        return app.staticTexts[text]
    }

    @discardableResult
    func waitForEducationView(locale: String,
                              timeout: TimeInterval = 15) -> Bool {
        educationIntroStaticText(locale: locale).waitForExistence(timeout: timeout)
    }

    /**
     Locale-dependent probe for the capture-suggestions banner
     (`ginicapture.analysis.suggestion.1`). The banner surfaces on the image
     path only — for PDF fixtures the probe times out; callers should skip
     when it does not appear.
     */
    func captureSuggestionsBannerStaticText(locale: String) -> XCUIElement {
        let text: String
        switch locale {
        case "de": text = "Gute Lichtverhältnisse"
        default:   text = "Good lighting"
        }
        return app.staticTexts[text]
    }

    @discardableResult
    func waitForCaptureSuggestionsBanner(locale: String,
                                         timeout: TimeInterval = 15) -> Bool {
        captureSuggestionsBannerStaticText(locale: locale).waitForExistence(timeout: timeout)
    }
}
