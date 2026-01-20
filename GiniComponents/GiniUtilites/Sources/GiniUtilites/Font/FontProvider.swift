//
//  FontProvider.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import SwiftUI

public final class FontProvider {
    private var textStyleFonts = FontProvider.defaultFonts

    public init() {
        //empty initializer for public acces
    }

    /**
     Allows setting a custom font for specific text styles. The change will affect all screens where a specific text style was used.

     - parameter font: Font that is going to be associated with specific text style. You can use scaled font or scale your font with our util method `UIFont.scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle)`
     - parameter textStyle: Constants that describe the preferred styles for fonts. Please, find additional information [here](https://developer.apple.com/documentation/uikit/uifont/textstyle)
     */
    public func updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle) {
        textStyleFonts[textStyle] = font
    }

    /**
     Retrieves the font associated with a specific text style.
     - parameter textStyle: The text style for which to retrieve the font.
     - returns: The font associated with the given text style.
     */
    public func font(for textStyle: UIFont.TextStyle) -> UIFont {
        return textStyleFonts[textStyle] ?? UIFont.systemFont(ofSize: 17)
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
    private static func createFont(textStyle: UIFont.TextStyle, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }

    private static let defaultFonts : [UIFont.TextStyle: UIFont] = [
        .headline1: createFont(textStyle: .headline, size: 26, weight: .regular),
        .headline2: createFont(textStyle: .headline, size: 20, weight: .bold),
        .headline3: createFont(textStyle: .headline, size: 18, weight: .bold),
        .captions1: createFont(textStyle: .caption1, size: 13, weight: .regular),
        .captions2: createFont(textStyle: .caption2, size: 12, weight: .regular),
        .linkBold: createFont(textStyle: .footnote, size: 14, weight: .bold),
        .subtitle1: createFont(textStyle: .subheadline, size: 16, weight: .bold),
        .subtitle2: createFont(textStyle: .subheadline, size: 14, weight: .medium),
        .input: createFont(textStyle: .caption1, size: 16, weight: .medium),
        .button: createFont(textStyle: .caption2, size: 16, weight: .bold),
        .body1: createFont(textStyle: .body, size: 16, weight: .regular),
        .body2: createFont(textStyle: .body, size: 14, weight: .regular)
    ]
}

