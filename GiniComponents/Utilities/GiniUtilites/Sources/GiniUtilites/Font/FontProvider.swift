//
//  FontProvider.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import SwiftUI

public final class FontProvider {

    // Base font specification — stores the design-time values, not a pre-scaled instance.
    private struct FontSpec {
        let size: CGFloat
        let weight: UIFont.Weight
        /// The UIKit text style used by `UIFontMetrics` to scale `size` at call time.
        let scalingStyle: UIFont.TextStyle
    }

    // Per-text-style base specs (never scaled; computed fresh on every `font(for:)` call).
    private var fontSpecs: [UIFont.TextStyle: FontSpec] = FontProvider.defaultSpecs

    // Custom UIFont overrides registered by the host app via `updateFont(_:for:)`.
    private var customFonts: [UIFont.TextStyle: UIFont] = [:]

    public init() {}

    /**
     Allows setting a custom font for specific text styles. The change will affect all screens where a specific text style was used.

     - parameter font: Font that is going to be associated with specific text style. You can use scaled font or scale your font with our util method `UIFont.scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle)`
     - parameter textStyle: Constants that describe the preferred styles for fonts. Please, find additional information [here](https://developer.apple.com/documentation/uikit/uifont/textstyle)
     */
    public func updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle) {
        customFonts[textStyle] = font
    }

    /**
     Retrieves the font associated with a specific text style.

     The returned `UIFont` is computed fresh on every call using `UIFontMetrics`, so it always
     reflects the user's **current** Dynamic Type size — including changes made while the app is running.

     - parameter textStyle: The text style for which to retrieve the font.
     - returns: The font associated with the given text style.
     */
    public func font(for textStyle: UIFont.TextStyle) -> UIFont {
        if let custom = customFonts[textStyle] {
            return custom
        }
        guard let spec = fontSpecs[textStyle] else {
            return UIFont.systemFont(ofSize: 17)
        }
        let base = UIFont.systemFont(ofSize: spec.size, weight: spec.weight)
        return UIFontMetrics(forTextStyle: spec.scalingStyle).scaledFont(for: base)
    }

    /**
     Retrieves the SwiftUI `Font` associated with a specific text style.

     The returned `Font` wraps a freshly-computed `UIFont`, so it reflects the current Dynamic Type
     size at the moment it is called.

     - parameter textStyle: The text style for which to retrieve the SwiftUI font.
     - returns: A `SwiftUI.Font` created from the associated `UIFont`.
     */
    public func font(for textStyle: UIFont.TextStyle) -> Font {
        let giniFont: UIFont = font(for: textStyle)
        return Font(giniFont: giniFont)
    }
}

// MARK: - Private

private extension FontProvider {

    /// Design-time specifications for every Gini text style.
    /// Values are **not** pre-scaled; `font(for:)` applies `UIFontMetrics` at call time.
    private static let defaultSpecs: [UIFont.TextStyle: FontSpec] = [
        .headline1:  FontSpec(size: 26, weight: .regular, scalingStyle: .headline),
        .headline2:  FontSpec(size: 20, weight: .bold,    scalingStyle: .headline),
        .headline3:  FontSpec(size: 18, weight: .bold,    scalingStyle: .headline),
        .captions1:  FontSpec(size: 13, weight: .regular, scalingStyle: .caption1),
        .captions2:  FontSpec(size: 12, weight: .regular, scalingStyle: .caption2),
        .linkBold:   FontSpec(size: 14, weight: .bold,    scalingStyle: .footnote),
        .subtitle1:  FontSpec(size: 16, weight: .bold,    scalingStyle: .subheadline),
        .subtitle2:  FontSpec(size: 14, weight: .medium,  scalingStyle: .subheadline),
        .input:      FontSpec(size: 16, weight: .medium,  scalingStyle: .caption1),
        .button:     FontSpec(size: 16, weight: .bold,    scalingStyle: .caption2),
        .body1:      FontSpec(size: 16, weight: .regular, scalingStyle: .body),
        .body2:      FontSpec(size: 14, weight: .regular, scalingStyle: .body),
    ]
}
