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

    func limitingFontSize(to fontSizeLimit: CGFloat) -> UIFont {
        if self.pointSize > fontSizeLimit {
            return self.withSize(fontSizeLimit)
        } else {
            return self
        }
    }
}

extension UIFont.TextStyle {

    public static let bodyBold: UIFont.TextStyle = .init(rawValue: "kBodyBold")
    public static let calloutBold: UIFont.TextStyle = .init(rawValue: "kCalloutBold")
    public static let footnoteBold: UIFont.TextStyle = .init(rawValue: "kFootnoteBold")
    public static let title2Bold: UIFont.TextStyle = .init(rawValue: "kTitle2Bold")
    public static let title1Bold: UIFont.TextStyle = .init(rawValue: "kTitle1Bold")
    public static let caption1SemiBold: UIFont.TextStyle = .init(rawValue: "KCaption1SemiBold")
}
