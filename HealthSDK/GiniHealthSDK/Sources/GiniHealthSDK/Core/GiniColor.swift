//
//  GiniColor.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `GiniColor` class allows to customize color for the light and the dark modes.
 */

@objc public class GiniColor : NSObject {
    var lightModeColor: UIColor
    var darkModeColor: UIColor

    /**
     Creates a GiniColor with the colors for the light and dark modes
     
     - parameter lightModeColor: color for the light mode
     - parameter darkModeColor: color for the dark mode
     */
    public init(lightModeColor: UIColor, darkModeColor: UIColor) {
        self.lightModeColor = lightModeColor
        self.darkModeColor = darkModeColor
    }
    
    func uiColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return self.darkModeColor
                } else {
                    /// Return the color for Light Mode
                    return self.lightModeColor
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return self.lightModeColor
        }
    }
}
