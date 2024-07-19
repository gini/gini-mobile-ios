//
//  GiniColor.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

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
     Creates a GiniColor with the color names for the light and dark modes
     
     - parameter lightModeColorName: color name for the light mode
     - parameter darkModeColorName: color name for the dark mode
     */
    convenience init(lightModeColorName: GiniMerchantColorPalette, darkModeColorName: GiniMerchantColorPalette) {
        let lightColor = lightModeColorName.preferredColor()
        let darkColor = darkModeColorName.preferredColor()
        self.init(lightModeColor: lightColor, darkModeColor: darkColor)
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
}

extension GiniColor {
    static let standard1 = GiniColor(lightModeColorName: .dark1, darkModeColorName: .light1)
    static let standard2 = GiniColor(lightModeColorName: .dark2, darkModeColorName: .light2)
    static let standard3 = GiniColor(lightModeColorName: .dark3, darkModeColorName: .light3)
    static let standard4 = GiniColor(lightModeColorName: .dark4, darkModeColorName: .light4)
    static let standard5 = GiniColor(lightModeColorName: .dark5, darkModeColorName: .light5)
    static let standard6 = GiniColor(lightModeColorName: .dark6, darkModeColorName: .light6)
    static let standard7 = GiniColor(lightModeColorName: .dark7, darkModeColorName: .light7)
    
    static let accent1 = GiniColor(lightModeColorName: .accent1, darkModeColorName: .accent1)

    static let feedback1 = GiniColor(lightModeColorName: .feedback1, darkModeColorName: .feedback1)
}

public extension UIColor {
    static func from(giniColor: GiniColor) -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? giniColor.darkModeColor : giniColor.lightModeColor
        }
    }
}
