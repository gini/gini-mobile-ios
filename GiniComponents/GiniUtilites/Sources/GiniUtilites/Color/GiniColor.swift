//
//  GiniColor.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import SwiftUI

/**
 The `GiniColor` class allows to customize color for the light and the dark modes.
 */

public class GiniColor: NSObject {
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
    
    /**
     Returns the appropriate color for the current user interface style.
     
     - returns: UIColor based on the current user interface style.
     */
    public func uiColor() -> UIColor {
        return UIColor { traitCollection -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? self.darkModeColor : self.lightModeColor
        }
    }
    
    /**
     Converts the `GiniColor` to a SwiftUI `Color`, maintaining the light/dark mode support
     based on the current user interface style.
     
     - returns: A SwiftUI `Color` that adapts to light and dark mode.
     */
    public func swiftUIColor() -> Color {
        Color(self.uiColor())
    }
}

public extension UIColor {
    static func from(giniColor: GiniColor) -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? giniColor.darkModeColor : giniColor.lightModeColor
        }
    }
}
