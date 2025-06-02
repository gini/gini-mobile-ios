//
//  UIDevice.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIDevice {
    var isIpad: Bool {
        return self.userInterfaceIdiom == .pad
    }

    var isIphone: Bool {
        return self.userInterfaceIdiom == .phone
    }

    var isSmallIphone: Bool {
        guard isIphone else {
            return false
        }
        let screenSize = UIScreen.main.bounds.size
        let smallestDimension = min(screenSize.width, screenSize.height)
        // iphone 5s smallest dimension seems to be 320px, but we're gonna check for a bit higher value
        // iphone 6/6s/8 and similar seem to have 375px
        let minSize: CGFloat = 350
        return smallestDimension <= minSize
    }

    /// Returns true if the current device is currently in landscape orientation.
    var isLandscape: Bool {
        !isPortrait()
    }

    /// Returns true if the current device is an iPhone and is currently in landscape orientation.
    var isIphoneAndLandscape: Bool {
        isIphone && isLandscape
    }

    private func isPortrait() -> Bool {
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
