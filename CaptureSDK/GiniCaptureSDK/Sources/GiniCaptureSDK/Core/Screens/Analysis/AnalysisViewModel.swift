//
//  AnalysisViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 View model for `AnalysisViewController`. Owns feature-flag reads that would
 otherwise live in the view controller, keeping the VC UI-only per the repo's
 MVVM + Coordinator standard. Scope grows as more non-UI state moves out.
 */
protocol AnalysisViewModel: AnyObject {
    /**
     `true` when `ingredientBrandScreens` includes the Analysis screen.
     */
    var isIngredientBrandEnabled: Bool { get }
}

/**
 Reads `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` on every access so
 `/configurations` updates propagate without recreating the VC.
 */
final class LiveAnalysisViewModel: AnalysisViewModel {
    var isIngredientBrandEnabled: Bool {
        IngredientBrandScreen.isEnabled(IngredientBrandScreen.analysis,
                                        in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens)
    }
}
