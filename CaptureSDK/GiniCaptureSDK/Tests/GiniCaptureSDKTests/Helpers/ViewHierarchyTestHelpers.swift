//
//  ViewHierarchyTestHelpers.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Shared helpers for traversing view hierarchies and simulating control taps
 deterministically in unit tests (without relying on a running UIApplication).
 */
enum ViewHierarchyTestHelper {

    /// Returns the first view of the given type found via depth-first traversal.
    @MainActor
    static func firstView<T: UIView>(ofType type: T.Type,
                                     in root: UIView) -> T? {
        if let match = root as? T {
            return match
        }
        for subview in root.subviews {
            if let match = firstView(ofType: type, in: subview) {
                return match
            }
        }
        return nil
    }

    /// Returns the first `UILabel` whose text matches the given string.
    @MainActor
    static func firstLabel(withText text: String,
                           in root: UIView) -> UILabel? {
        if let label = root as? UILabel, label.text == text {
            return label
        }
        for subview in root.subviews {
            if let match = firstLabel(withText: text, in: subview) {
                return match
            }
        }
        return nil
    }

    /**
     Compares two colors by resolving them for both light and dark mode.

     Dynamic-provider colors (e.g. `GiniColor.uiColor()`) create a new instance
     on every call, so direct `==` comparison of such colors always fails.
     */
    @MainActor
    static func colorsEqual(_ lhs: UIColor?,
                            _ rhs: UIColor?) -> Bool {
        guard let lhs, let rhs else {
            return lhs == nil && rhs == nil
        }
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        return lhs.resolvedColor(with: light) == rhs.resolvedColor(with: light)
            && lhs.resolvedColor(with: dark) == rhs.resolvedColor(with: dark)
    }

    /**
     Simulates a `.touchUpInside` tap by invoking every registered
     target/action pair directly. This avoids `sendActions(for:)`,
     which depends on a running `UIApplication` event loop.
     */
    @MainActor
    static func tap(_ control: UIControl) {
        for target in control.allTargets {
            guard let object = target as? NSObject else { continue }
            let actions = control.actions(forTarget: object,
                                          forControlEvent: .touchUpInside) ?? []
            for action in actions {
                _ = object.perform(Selector(action))
            }
        }
    }
}
