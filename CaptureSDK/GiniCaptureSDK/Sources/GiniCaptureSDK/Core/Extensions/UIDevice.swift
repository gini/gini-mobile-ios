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
        orientation.isLandscape
    }

    /// Returns true if the current device is an iPhone and is currently in landscape orientation.
    var isIphoneAndLandscape: Bool {
        isIphone && isLandscape
    }
}
