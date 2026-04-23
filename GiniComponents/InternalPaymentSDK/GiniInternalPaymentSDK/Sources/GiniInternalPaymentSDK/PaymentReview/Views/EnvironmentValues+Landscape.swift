//
//  EnvironmentValues+Landscape.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    /**
     `true` when the device is in landscape orientation.
     On iPhone this maps to `verticalSizeClass == .compact`; iPads always return `.regular`
     for both orientations so landscape there is handled separately via the portrait/sheet flow.
     */
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
}
