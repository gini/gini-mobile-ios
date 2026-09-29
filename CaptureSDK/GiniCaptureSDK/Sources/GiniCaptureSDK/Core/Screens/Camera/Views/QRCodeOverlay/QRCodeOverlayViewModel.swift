//
//  QRCodeOverlayViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 View model for `QRCodeOverlay`. Owns non-UI concerns (feature-flag reads,
 configuration lookups) so the view only lays out UI, per the repo's
 MVVM + Coordinator standard.
 */
protocol QRCodeOverlayViewModel: AnyObject {
    /**
     `true` when `ingredientBrandScreens` includes the Analysis screen.
     Drives whether the overlay installs the "Powered by Gini" badge and
     the branded `PoweredByGiniLoadingIndicatorView` in place of the
     standard spinner.
     */
    var isIngredientBrandEnabled: Bool { get }
}

/**
 Production implementation reading
 `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` on every access,
 so downstream `/configurations` updates propagate without recreating the
 overlay. Tests substitute a stub conforming to `QRCodeOverlayViewModel`
 and injected via `QRCodeOverlay.init(viewModel:)`.
 */
final class LiveQRCodeOverlayViewModel: QRCodeOverlayViewModel {
    var isIngredientBrandEnabled: Bool {
        IngredientBrandScreen.isEnabled(IngredientBrandScreen.analysis,
                                        in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens)
    }
}
