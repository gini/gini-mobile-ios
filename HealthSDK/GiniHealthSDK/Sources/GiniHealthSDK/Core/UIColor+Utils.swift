//
//  UIColor+Utils.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 07.04.21.
//

import UIKit
public extension UIColor {
    static func from(giniColor: GiniColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return giniColor.darkModeColor
                } else {
                    /// Return the color for Light Mode
                    return giniColor.lightModeColor
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return giniColor.lightModeColor
        }
    }
    
     static func from(hex: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
