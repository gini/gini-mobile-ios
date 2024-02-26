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
}
