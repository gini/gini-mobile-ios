//
//  UIFont.swift
//  
//
//  Created by Nadya Karaban on 09.08.22.
//

import UIKit

extension UIFont {
    /**
     - parameter font: The font to be scaled. Do not specify a font that has already been scaled; doing so results in an exception
     - parameter textStyle: Constants that describe the preferred styles for fonts. Please, find additional information [here](https://developer.apple.com/documentation/uikit/uifont/textstyle)
     
     - returns: A scaled font for a specific text style.
     */
    public static func scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle) -> UIFont {
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
