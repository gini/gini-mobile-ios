//
//  GiniMerchantColors.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

enum GiniMerchantColorPalette: String {
    case accent1 = "Accent01"
    case accent2 = "Accent02"
    case accent3 = "Accent03"
    case accent4 = "Accent04"
    case accent5 = "Accent05"
    
    case dark1 = "Dark01"
    case dark2 = "Dark02"
    case dark3 = "Dark03"
    case dark4 = "Dark04"
    case dark5 = "Dark05"
    case dark6 = "Dark06"
    case dark7 = "Dark07"
    
    case light1 = "Light01"
    case light2 = "Light02"
    case light3 = "Light03"
    case light4 = "Light04"
    case light5 = "Light05"
    case light6 = "Light06"
    case light7 = "Light07"
    
    case feedback1 = "Feedback01"
    case feedback2 = "Feedback02"
    case feedback3 = "Feedback03"
    case feedback4 = "Feedback04"
    
    case success1 = "Success01"
    case success2 = "Success02"
    case success3 = "Success03"
    case success4 = "Success04"
}

extension GiniMerchantColorPalette {
    func preferredColor() -> UIColor {
        let name = self.rawValue
        if let mainBundleColor = UIColor(named: name, in: Bundle.main, compatibleWith: nil) {
            return mainBundleColor
        }

        guard let color = UIColor(named: name, in: giniMerchantBundleResource(), compatibleWith: nil) else {
            fatalError("The color named '\(name)' does not exist.")
        }
        
        return color
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

extension GiniColor {
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
}
