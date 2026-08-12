//
//  UIDevice.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIDevice {

    /// Returns `true` when the active interface orientation is portrait (or portrait-upside-down).
    ///
    /// **Must be called on the main thread.** All UIKit scene and orientation APIs accessed
    /// here are main-thread–only; the caller is responsible for ensuring main-thread execution
    /// (all current call sites are UIKit lifecycle methods already running on the main thread).
    ///
    /// **Scene selection strategy (iOS 16+):** key-window scene → foreground-active scene →
    /// first connected scene.  Preferring the key-window scene means the correct orientation
    /// is returned even in multi-window configurations (e.g. iPad Split View / Slide Over),
    /// where the foreground-active scene might belong to a *different* window than the one
    /// hosting the UI that is being laid out.
    static func isPortrait() -> Bool {
        // iOS 16 and higher - prefer the window scene's interface orientation.
        if #available(iOS 16.0, *) {
            // 1. Prefer the scene that owns the key window — the most reliable proxy for
            //    "the scene the user is currently interacting with" in multi-window setups.
            // 2. Fall back to the foreground-active scene for cases where no key window
            //    has been established yet (e.g. very early in app launch).
            // 3. Last resort: first connected scene.
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.windows.contains(where: { $0.isKeyWindow }) })
                ?? UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first(where: { $0.activationState == .foregroundActive })
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
            // 1. Check first the window orientation (more reliable than statusBarOrientation).
            //    Prefer the key-window scene for the same multi-window reason as the iOS 16 path.
            let candidateScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.windows.contains(where: { $0.isKeyWindow }) })
                ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
            if let windowScene = candidateScene {
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
