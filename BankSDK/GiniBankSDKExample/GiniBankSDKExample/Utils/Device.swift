//
//  Device.swift
//  GiniBankSDKExample
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

class Device {
    @available(*, deprecated, message: "use Device.small(in:) instead")
    static var small: Bool {
        return small(bounds: UIScreen.main.bounds)
    }

    static func small(in view: UIView) -> Bool {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = view.window?.windowScene
            ?? scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first
        let bounds = scene?.screen.bounds ?? view.bounds
        return small(bounds: bounds)
    }

    private static func small(bounds: CGRect) -> Bool {
        return bounds.height <= 667 // Targets iPhone SE 1st Gen, 6/7/8, SE 2nd Gen
    }
}
