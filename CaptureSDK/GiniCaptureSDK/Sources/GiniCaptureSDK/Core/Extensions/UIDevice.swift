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
        if #available(iOS 16.0, *) {
            return interfaceOrientation?.isPortrait ?? UIDevice.current.orientation.isPortrait
        } else {

            // Check first the window orientation (more reliable than statusBarOrientation)
            guard let interfaceOrientation = interfaceOrientation else {
                // If we can't get the scene, we try with the physical orientation
                return UIDevice.current.orientation.isPortrait
            }

            let isWindowPortrait = interfaceOrientation.isPortrait
            let deviceOrientation = UIDevice.current.orientation

            if deviceOrientation == .unknown || deviceOrientation == .faceUp || deviceOrientation == .faceDown {
                return isWindowPortrait
            }
            return deviceOrientation.isPortrait
        }
    }

    var hasNotch: Bool {
        // This covers: iPhone SE (all generations), iPhone 6/6s/7/8 series
        guard let window = keyWindow else {
            return false
        }
        // Devices without notch have no bottom safe area (0pt)
        return window.safeAreaInsets.bottom > 0
    }

    // MARK: - Private helpers

    private var interfaceOrientation: UIInterfaceOrientation? {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation
    }

    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    }
}
