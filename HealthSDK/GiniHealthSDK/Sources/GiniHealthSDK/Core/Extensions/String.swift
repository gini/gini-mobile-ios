//
//  String.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

extension String {
    func toColor() -> UIColor? {
        return UIColor(hex: String.rgbaHexFrom(rgbHex: self))
    }
    
    func canOpenURLString() -> Bool {
        if let url = URL(string: self) {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
}
