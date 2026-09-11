//
//  PoweredByGiniBadgeViewTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniUtilites

@Suite("PoweredByGiniBadgeView — fixed-size branded ingredient badge")
@MainActor
struct PoweredByGiniBadgeViewTests {

    @Test("intrinsicContentSize is 90x23")
    func intrinsicContentSizeMatchesDesign() {
        let view = PoweredByGiniBadgeView()

        #expect(view.intrinsicContentSize == CGSize(width: 90, height: 23),
                "Expected the badge to expose a fixed 90x23 intrinsic content size")
    }

    @Test("The badge itself is the a11y element, not the inner image")
    func accessibilityContainerIsBadgeNotImage() {
        let view = PoweredByGiniBadgeView()
        let imageView = view.subviews.compactMap { $0 as? UIImageView }.first

        #expect(view.isAccessibilityElement == true,
                "Expected the badge view to be a single a11y element")
        #expect(view.accessibilityLabel == "Powered by Gini",
                "Expected the a11y label to be the hardcoded English brand phrase")
        #expect(imageView?.isAccessibilityElement == false,
                "Expected the inner UIImageView to be excluded from VoiceOver focus")
    }

    @Test("Accessibility traits include .image")
    func accessibilityTraitsIncludeImage() {
        let view = PoweredByGiniBadgeView()

        #expect(view.accessibilityTraits.contains(.image),
                "Expected the badge to expose the .image trait")
    }

    /// Fails if `resources: [.process("Resources")]` is missing from either GiniUtilites
    /// manifest — `UIImage(named:in:.module)` returns nil and the badge renders blank.
    @Test("The badge image loads from the GiniUtilites .module bundle")
    func imageLoadsFromModuleBundle() {
        let view = PoweredByGiniBadgeView()
        let imageView = view.subviews.compactMap { $0 as? UIImageView }.first

        #expect(imageView?.image != nil,
                "Expected the poweredByGiniBadge PDF to be loaded from the GiniUtilites module bundle")
    }

    @Test("isHidden also flips accessibilityElementsHidden so VoiceOver skips the badge")
    func isHiddenMirrorsAccessibilityElementsHidden() {
        let view = PoweredByGiniBadgeView()
        #expect(view.accessibilityElementsHidden == false,
                "Expected the badge to be a11y-visible by default")

        view.isHidden = true
        #expect(view.accessibilityElementsHidden == true,
                "Expected accessibilityElementsHidden to follow isHidden = true so VoiceOver skips the hidden badge")

        view.isHidden = false
        #expect(view.accessibilityElementsHidden == false,
                "Expected accessibilityElementsHidden to follow isHidden = false when the badge becomes visible again")
    }
}
