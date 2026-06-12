//
//  UIFont.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension UIFont.TextStyle {
    public static let headline1: UIFont.TextStyle = .init(rawValue: "kHeadline1")
    public static let headline2: UIFont.TextStyle = .init(rawValue: "kHeadline2")
    public static let headline3: UIFont.TextStyle = .init(rawValue: "kHeadline3")
    public static let linkBold: UIFont.TextStyle = .init(rawValue: "kLinkBold")
    public static let subtitle1: UIFont.TextStyle = .init(rawValue: "kSubtitle1")
    public static let subtitle2: UIFont.TextStyle = .init(rawValue: "kSubtitle2")
    public static let input: UIFont.TextStyle = .init(rawValue: "kInput")
    public static let button: UIFont.TextStyle = .init(rawValue: "kButton")
    public static let body1: UIFont.TextStyle = .init(rawValue: "kBody1")
    public static let body2: UIFont.TextStyle = .init(rawValue: "kBody2")
    public static let captions1: UIFont.TextStyle = .init(rawValue: "kCaptions1")
    public static let captions2: UIFont.TextStyle = .init(rawValue: "kCaptions2")
}

extension UIFont {

    /**
     Returns a version of the font capped at `fontSizeLimit`, but only when the user has enabled
     an accessibility text size (AX1–AX5 via Settings → Accessibility → Display & Text Size).
     At regular text sizes the font is returned unchanged.
     - Parameters:
       - fontSizeLimit: The maximum point size to allow under accessibility text sizes.
     - Returns: The capped font when an accessibility category is active; otherwise the original font.
     */
    public func limitingFontSize(to fontSizeLimit: CGFloat) -> UIFont {
        guard UITraitCollection.current.preferredContentSizeCategory.isAccessibilityCategory else {
            return self
        }
        return self.pointSize > fontSizeLimit ? self.withSize(fontSizeLimit) : self
    }
}
