//
//  DeviceOrientation.swift
//
//
// Copyright © 2023 Gini GmbH. All rights reserved
//

import UIKit

enum Device {

    /**
     * This property tries to get 4 orientations:
     * landscapeLeft, landscapeRight, portrait, portraitUpsideDown
     * as defined by UIDeviceOrientation enum.
     * It can return also unknown orientation (which is rare case)
     */
    static var orientation: UIDeviceOrientation {

        // otherwise if there is flat (faceUp, faceDown), unknown orientation
        // try to get orientation from UIInterfaceOrientation
        // Notice that:
        // UIDeviceOrientationLandscapeRight => UIInterfaceOrientationLandscapeLeft
        // UIDeviceOrientationLandscapeLeft => UIInterfaceOrientationLandscapeRight

        let interfaceOrientation = UIWindow.orientation
        switch interfaceOrientation {
        case .landscapeLeft:
            return UIDeviceOrientation.landscapeRight
        case .landscapeRight:
            return UIDeviceOrientation.landscapeLeft
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .unknown:
            break
        @unknown default:
            break
        }

        return .unknown
    }
}
