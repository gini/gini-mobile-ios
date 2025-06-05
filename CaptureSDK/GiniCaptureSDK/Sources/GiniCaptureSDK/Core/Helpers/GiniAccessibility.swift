//
//  GiniAccessibility.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A utility for accessibility-related helpers.
 */
public enum GiniAccessibility {

    /**
     Indicates whether the user has enabled an accessibility-level font size.

     Returns `true` when the current `UIContentSizeCategory` is greater than or equal to
     `.accessibilityMedium`, which typically corresponds to a font scaling factor of around 200% or more.

     Use this to adjust layouts or content spacing for users with significantly enlarged fonts.
     */
    public static var isFontSizeAtLeastAccessibilityMedium: Bool {
        return UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium
    }
}

