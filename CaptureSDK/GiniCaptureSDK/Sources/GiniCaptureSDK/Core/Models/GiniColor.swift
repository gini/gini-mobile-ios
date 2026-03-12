//
//  GiniColor.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
import UIKit
/**
 The `GiniColor` class allows to customize color for the light and the dark modes.
 */
public class GiniColor: NSObject {
    var light: UIColor
    var dark: UIColor

    /**
     Creates a GiniColor with the colors for the light and dark modes.

     - parameter light: color for the light mode
     - parameter dark: color for the dark mode
     */
    public init(light: UIColor, dark: UIColor) {
        self.light = light
        self.dark = dark
    }

    public func uiColor() -> UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return self.dark
            } else {
                /// Return the color for Light Mode
                return self.light
            }
        }
    }
}
