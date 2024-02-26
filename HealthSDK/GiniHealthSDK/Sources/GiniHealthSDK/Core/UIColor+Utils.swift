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
    
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }

    struct GiniHealthColors {
        static let accent1 = UIColorPreferred(named: "Accent01")
        static let accent2 = UIColorPreferred(named: "Accent02")
        static let accent3 = UIColorPreferred(named: "Accent03")
        static let accent4 = UIColorPreferred(named: "Accent04")
        static let accent5 = UIColorPreferred(named: "Accent05")

        static let dark1 = UIColorPreferred(named: "Dark01")
        static let dark2 = UIColorPreferred(named: "Dark02")
        static let dark3 = UIColorPreferred(named: "Dark03")
        static let dark4 = UIColorPreferred(named: "Dark04")
        static let dark5 = UIColorPreferred(named: "Dark05")
        static let dark6 = UIColorPreferred(named: "Dark06")
        static let dark7 = UIColorPreferred(named: "Dark07")

        static let light1 = UIColorPreferred(named: "Light01")
        static let light2 = UIColorPreferred(named: "Light02")
        static let light3 = UIColorPreferred(named: "Light03")
        static let light4 = UIColorPreferred(named: "Light04")
        static let light5 = UIColorPreferred(named: "Light05")
        static let light6 = UIColorPreferred(named: "Light06")
        static let light7 = UIColorPreferred(named: "Light07")

        static let feedback1 = UIColorPreferred(named: "Feedback01")
        static let feedback2 = UIColorPreferred(named: "Feedback02")
        static let feedback3 = UIColorPreferred(named: "Feedback03")
        static let feedback4 = UIColorPreferred(named: "Feedback04")
    }
}
