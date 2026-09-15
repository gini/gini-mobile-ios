//
//  IngredientBrandScreen.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Named constants and membership check for the `ingredientBrandScreens`
 configuration list served by `/configurations` and stored in
 `GiniCaptureUserDefaultsStorage.ingredientBrandScreens`.

 Values arrive as raw strings from the backend and may drift in casing
 between environments. Callers should use these named constants and the
 case-insensitive `isEnabled(_:in:)` helper rather than raw string
 literals, so the two spellings can never diverge between call sites.
 */
enum IngredientBrandScreen {
    /// Screen identifier for the Analysis screen (Bank + Capture SDKs).
    static let analysis = "Analysis"

    /**
     Whether the given screen identifier is present in `screens`,
     matched case-insensitively.

     - Parameters:
       - screen: The screen identifier to look for; use one of the
         named constants on this type.
       - screens: The configured list, typically
         `GiniCaptureUserDefaultsStorage.ingredientBrandScreens`.
         `nil` and empty are both treated as "no screens enabled".
     - Returns: `true` if `screens` contains `screen` (case-insensitive),
       `false` otherwise.
     */
    static func isEnabled(_ screen: String, in screens: [String]?) -> Bool {
        (screens ?? []).contains { $0.caseInsensitiveCompare(screen) == .orderedSame }
    }
}
