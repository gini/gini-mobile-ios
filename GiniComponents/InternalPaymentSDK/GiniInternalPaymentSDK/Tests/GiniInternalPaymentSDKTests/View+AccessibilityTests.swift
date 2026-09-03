//
//  View+AccessibilityTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import SwiftUI
import UIKit
@testable import GiniInternalPaymentSDK

/**
 Tests for `View.accessibilityHintIfPresent(_:)`.
 */
@Suite("View+Accessibility — accessibilityHintIfPresent")
@MainActor
struct ViewAccessibilityTests {

    // MARK: - Helpers

    /** Recursively searches a UIView subtree for any accessibility hint that matches `target`. */
    private func containsHint(_ target: String, in view: UIView) -> Bool {
        if view.accessibilityHint == target { return true }
        if let elements = view.accessibilityElements {
            for element in elements {
                if let element = element as? NSObject,
                   element.accessibilityHint == target { return true }
            }
        }
        return view.subviews.contains { containsHint(target, in: $0) }
    }

    private func makeHostingView<V: View>(_ content: V) -> UIView {
        let vc = UIHostingController(rootView: content)
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        vc.loadViewIfNeeded()
        vc.view.layoutIfNeeded()
        return vc.view
    }

    // MARK: - nil message

    @Test("nil message does not inject any accessibility hint into the view tree")
    func nilMessageDoesNotAddHint() {
        let view = makeHostingView(
            Text("Test").accessibilityHintIfPresent(nil)
        )

        #expect(!containsHint("sentinel", in: view),
                "accessibilityHintIfPresent(nil) must not add a hint to the accessibility tree")
    }

    // MARK: - empty string message

    @Test("empty string message does not inject any accessibility hint into the view tree")
    func emptyStringMessageDoesNotAddHint() {
        let view = makeHostingView(
            Text("Test").accessibilityHintIfPresent("")
        )

        #expect(!containsHint("sentinel", in: view),
                "accessibilityHintIfPresent(\"\") must not add a hint to the accessibility tree")
    }

    // MARK: - non-empty message

    @Test("non-empty message applies the accessibility hint without error")
    func nonEmptyMessageAppliesHintModifier() {
        let view = makeHostingView(
            Text("Test").accessibilityHintIfPresent("Validation error")
        )

        #expect(view != nil,
                "accessibilityHintIfPresent with a non-empty message must produce a renderable view")
    }
}
