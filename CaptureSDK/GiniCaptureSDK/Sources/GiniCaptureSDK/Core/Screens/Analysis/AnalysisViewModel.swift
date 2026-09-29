//
//  AnalysisViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 View model for `AnalysisViewController`. Owns non-UI concerns
 (feature-flag reads for the ingredient-brand path today) so the view
 controller only lays out UI, per the repo's MVVM + Coordinator standard.

 Scope is intentionally narrow to what the three ingredient-brand callsites
 need — the branded/custom/standard indicator precedence resolution stays
 in the view controller because it consults view-state (`hasValidAsset`)
 and `giniConfiguration.customLoadingIndicator` that the VM has no
 business knowing about. As more of the VC's non-UI state moves out over
 time, this VM is the natural home for it.
 */
protocol AnalysisViewModel: AnyObject {
    /**
     `true` when `ingredientBrandScreens` includes the Analysis screen.
     Drives whether `AnalysisViewController` creates the branded Gini
     loading indicator, installs the "Powered by Gini" badge, and swaps
     the education-carousel icons for the animated Gini `g` mark.
     */
    var isIngredientBrandEnabled: Bool { get }
}

/**
 Production implementation reading
 `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` on every access,
 so downstream `/configurations` updates propagate without recreating the
 view controller. Tests substitute a stub conforming to `AnalysisViewModel`
 and pass it via `@testable`-visible constructor injection.
 */
final class LiveAnalysisViewModel: AnalysisViewModel {
    var isIngredientBrandEnabled: Bool {
        IngredientBrandScreen.isEnabled(IngredientBrandScreen.analysis,
                                        in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens)
    }
}
