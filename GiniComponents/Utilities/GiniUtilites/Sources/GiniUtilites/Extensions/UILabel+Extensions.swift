//
//  UILabel+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

extension UILabel {
    
    public func enableScaling(scaleFactor: CGFloat = 10.0) {
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = scaleFactor / font.pointSize
        adjustsFontForContentSizeCategory = true
    }
}
