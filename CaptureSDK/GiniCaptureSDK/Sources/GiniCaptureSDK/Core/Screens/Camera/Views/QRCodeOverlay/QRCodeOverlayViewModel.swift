//
//  QRCodeOverlayViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 View model for `QRCodeOverlay`. Owns feature-flag reads (ingredient-brand today)
 that would otherwise live in the view, keeping the view UI-only per the repo's
 MVVM + Coordinator standard.
 */
protocol QRCodeOverlayViewModel: AnyObject {
    /**
     `true` when `ingredientBrandScreens` includes the Analysis screen.
     */
    var isIngredientBrandEnabled: Bool { get }
}

/**
 Reads `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` on every access so
 `/configurations` updates propagate without recreating the overlay.
 */
final class LiveQRCodeOverlayViewModel: QRCodeOverlayViewModel {
    var isIngredientBrandEnabled: Bool {
        IngredientBrandScreen.isEnabled(IngredientBrandScreen.analysis,
                                        in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens)
    }
}
