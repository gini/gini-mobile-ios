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
    
    public func limitingFontSize(to fontSizeLimit: CGFloat) -> UIFont {
        if self.pointSize > fontSizeLimit {
            return self.withSize(fontSizeLimit)
        } else {
            return self
        }
    }
}
