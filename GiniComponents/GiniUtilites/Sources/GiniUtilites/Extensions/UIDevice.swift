//
//  UIDevice.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIDevice {
    
    static func isPortrait() -> Bool {
        // iOS 16 and higher - the most reliable and up-to-date way
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return UIDevice.current.orientation.isPortrait
            }
            return windowScene.interfaceOrientation.isPortrait
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
