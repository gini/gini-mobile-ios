//
//  GiniColor.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 30.03.21.
//

import UIKit
/**
 The `Color` class allows us decode and encode the color
 */

public struct Color: Codable {
    private var red: CGFloat = 0.0
    private var green: CGFloat = 0.0
    private var blue: CGFloat = 0.0
    private var alpha: CGFloat = 0.0

    public var uiColor: UIColor {
        UIColor(red: red,
                       green: green,
                       blue: blue,
                       alpha: alpha)
    }

    public var giniColor: GiniColor {
        GiniColor(lightModeColor: uiColor, 
                  darkModeColor: uiColor)
    }

    public init(uiColor: UIColor) {
        uiColor.getRed(&red, 
                       green: &green,
                       blue: &blue,
                       alpha: &alpha)
    }
}

/**
 The `GiniColor` class allows to customize color for the light and the dark modes.
 */

@objc public class GiniColor : NSObject, Codable {
    var lightModeColor: Color
    var darkModeColor: Color

    /**
     Creates a GiniColor with the colors for the light and dark modes
     
     - parameter lightModeColor: color for the light mode
     - parameter darkModeColor: color for the dark mode
     */
    public init(lightModeColor: UIColor, darkModeColor: UIColor) {
        self.lightModeColor = Color(uiColor: lightModeColor)
        self.darkModeColor = Color(uiColor: darkModeColor)
    }
    
    func uiColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return self.darkModeColor.uiColor
                } else {
                    /// Return the color for Light Mode
                    return self.lightModeColor.uiColor
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return self.lightModeColor.uiColor
        }
    }
}
