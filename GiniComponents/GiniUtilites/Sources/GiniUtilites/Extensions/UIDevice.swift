//
//  UIDevice.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIDevice {
    
    static func isPortrait() -> Bool {
        // iOS 16 and higher - prefer the window scene's interface orientation.
        if #available(iOS 16.0, *) {
            // Prefer the foreground-active scene so we always read the live orientation
            // even during orientation transitions.
            let activeScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            
            let windowScene = activeScene
                ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
            
            guard let windowScene else {
                // No window scene available — fall back to physical orientation.
                // Use !isLandscape (not .isPortrait) so that .unknown/.faceUp/.faceDown
                // all default to portrait, matching the guard below.
                return !UIDevice.current.orientation.isLandscape
            }
            
            let interfaceOrientation = windowScene.interfaceOrientation
            
            // `.unknown` is returned when the scene has not yet finished its first
            // activation or when the orientation is queried mid-transition.
            // In that case fall back to the physical device orientation so that
            // portrait is never misidentified as landscape.
            guard interfaceOrientation != .unknown else {
                let deviceOrientation = UIDevice.current.orientation
                // isLandscape is false for unknown/flat orientations, so the
                // double-negation correctly defaults to portrait when uncertain.
                return !deviceOrientation.isLandscape
            }
            
            return interfaceOrientation.isPortrait
        } else {
            // 1. Check first the window orientation (more reliable than statusBarOrientation)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let windowOrientation = windowScene.interfaceOrientation
                let isWindowPortrait = windowOrientation == .portrait || windowOrientation == .portraitUpsideDown
                
                // 2. Check also the physical device orientation
                let deviceOrientation = UIDevice.current.orientation
                let isDevicePortrait = deviceOrientation == .portrait || deviceOrientation == .portraitUpsideDown
                
                // 3. If the device orientation is unknown or flat, trust the window
                if deviceOrientation == .unknown || deviceOrientation == .faceUp || deviceOrientation == .faceDown {
                    return isWindowPortrait
                }
                
                // 4. If the device orientation is already indicating the new orientation, trust it
                return isDevicePortrait
            }
            
            // If we can't get the scene, we try with the physical orientation
            return UIDevice.current.orientation.isPortrait
        }
    }
}
