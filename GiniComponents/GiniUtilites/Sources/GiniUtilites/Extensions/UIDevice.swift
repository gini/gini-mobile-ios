//
//  UIDevice.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIDevice {
    static func isPortrait() -> Bool {
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
            return true // Default to portrait if unknown
        }
        return orientation.isPortrait
    }
}
