//
//  EnvironmentValues+Landscape.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

/** Gini-specific layout helpers derived from the current SwiftUI environment.
 Using a dedicated type avoids adding unnamespaced properties to `EnvironmentValues`
 that could collide with names defined in the host application. */
struct GiniLayoutEnvironment {
    private let verticalSizeClass: UserInterfaceSizeClass?

    init(verticalSizeClass: UserInterfaceSizeClass?) {
        self.verticalSizeClass = verticalSizeClass
    }

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

extension EnvironmentValues {
    /** Gini-specific layout helpers. Use this instead of extending `EnvironmentValues` directly
     to avoid property name collisions with host application extensions. */
    var giniLayout: GiniLayoutEnvironment {
        GiniLayoutEnvironment(verticalSizeClass: verticalSizeClass)
    }
}
