//
//  UIDevice.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIDevice {
    static func isPortrait() -> Bool {
        if #available(iOS 13.0, *) {
            if let orientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation {
                if #available(iOS 16.0, *) {
                    return orientation.isPortrait
                } else {
                    return orientation == .portrait || orientation == .portraitUpsideDown
                }
            }
        } else {
            return UIApplication.shared.statusBarOrientation == .portrait ||
                   UIApplication.shared.statusBarOrientation == .portraitUpsideDown
        }
        return UIDevice.current.orientation.isPortrait
    }
}
