//
//  UIColor.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 12.10.20.
//

import UIKit

extension UIColor {
    public static func from(hex: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
