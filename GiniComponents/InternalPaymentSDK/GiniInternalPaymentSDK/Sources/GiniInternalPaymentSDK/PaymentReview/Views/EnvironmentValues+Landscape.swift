//
//  EnvironmentValues+Landscape.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    /**
     `true` when the current environment uses a compact vertical size class.
     On iPhone this commonly maps to landscape orientation. On iPad, size classes can vary
     depending on multitasking and window size, so iPad landscape handling in this flow is
     managed separately via the portrait/sheet flow.
     */
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
}
