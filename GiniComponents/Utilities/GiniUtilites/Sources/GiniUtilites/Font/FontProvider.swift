//
//  FontProvider.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import SwiftUI

public final class FontProvider {
    /// Custom fonts set by the integrator via `updateFont(_:for:)`.
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
     Retrieves the font associated with a specific text style, scaled to the current Dynamic Type size.

     Custom fonts registered via `updateFont(_:for:)` are returned as-is.
     Built-in fonts are re-scaled on every call via `UIFontMetrics` so that
     the returned font always reflects the current content-size category.

     - parameter textStyle: The text style for which to retrieve the font.
     - returns: The font associated with the given text style.
     */
    public func font(for textStyle: UIFont.TextStyle) -> UIFont {
        if let custom = customFonts[textStyle] {
            return custom
        }
        guard let spec = FontProvider.defaultFontSpecs[textStyle] else {
            return UIFont.systemFont(ofSize: 17)
        }
        return UIFontMetrics(forTextStyle: spec.metricsStyle).scaledFont(for: spec.baseFont)
    }

    /**
     Retrieves the SwiftUI `Font` associated with a specific text style.

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
    struct FontSpec {
        let baseFont: UIFont
        let metricsStyle: UIFont.TextStyle
    }

    /// Static table of unscaled base fonts and their associated `UIFontMetrics` text style.
    /// Scaling is applied fresh on each call to `font(for:)` so the returned font always
    /// reflects the current Dynamic Type size category.
    static let defaultFontSpecs: [UIFont.TextStyle: FontSpec] = {
        func spec(_ metricsStyle: UIFont.TextStyle, size: CGFloat, weight: UIFont.Weight) -> FontSpec {
            FontSpec(baseFont: UIFont.systemFont(ofSize: size, weight: weight),
                     metricsStyle: metricsStyle)
        }
        return [
            .headline1: spec(.headline,    size: 26, weight: .regular),
            .headline2: spec(.headline,    size: 20, weight: .bold),
            .headline3: spec(.headline,    size: 18, weight: .bold),
            .captions1: spec(.caption1,    size: 13, weight: .regular),
            .captions2: spec(.caption2,    size: 12, weight: .regular),
            .linkBold:  spec(.footnote,    size: 14, weight: .bold),
            .subtitle1: spec(.subheadline, size: 16, weight: .bold),
            .subtitle2: spec(.subheadline, size: 14, weight: .medium),
            .input:     spec(.caption1,    size: 16, weight: .medium),
            .button:    spec(.caption2,    size: 16, weight: .bold),
            .body1:     spec(.body,        size: 16, weight: .regular),
            .body2:     spec(.body,        size: 14, weight: .regular),
        ]
    }()
}
