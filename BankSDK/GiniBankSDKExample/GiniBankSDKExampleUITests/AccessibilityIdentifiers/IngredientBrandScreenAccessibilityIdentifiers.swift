//
//  IngredientBrandScreenAccessibilityIdentifiers.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Accessibility identifiers exposed by `AnalysisViewController` in `GiniCaptureSDK`
 for the Ingredient Brand feature. Values must stay byte-identical to the SDK's
 `AnalysisViewController.AccessibilityIdentifiers` struct
 (`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Analysis/AnalysisViewController.swift`)
 — duplication is intentional because the UITest target cannot import the SDK.
 */
struct IngredientBrandScreenAccessibilityIdentifiers {

    /**
     Default loading state (flag off / no branded indicator).
     */
    static let defaultLoadingIndicator = "analysis.defaultLoadingIndicator"

    struct IngredientBrand {
        static let poweredByGiniLoadingIndicator = "analysis.ingredientBrand.poweredByGiniLoadingIndicator"
        static let poweredByGiniBadge = "analysis.ingredientBrand.poweredByGiniBadge"
    }

    /**
     Integrator-injected `CustomLoadingIndicatorAdapter` — the UI-test
     stand-in exposes this identifier on its injected view. Value must stay
     byte-identical to `UITestCustomLoadingIndicator.accessibilityID`.
     */
    static let customLoadingIndicator = "analysis.customLoadingIndicator"

    /**
     Invisible marker views on the key window flipped visible from
     `ScreenAPICoordinator` DEBUG hooks; used by tests to observe delegate
     callbacks without coupling to results-screen UI.
     */
    struct DelegateObservers {
        static let didCancelCapturing = "uitest.observer.didCancelCapturing"
        static let giniCaptureAnalysisDidFinish = "uitest.observer.giniCaptureAnalysisDidFinishWith"
    }
}
