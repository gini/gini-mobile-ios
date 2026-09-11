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

    @Test("intrinsicContentSize matches the Figma badge size (90x23)")
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

    /**
     Regression guard for resource-bundle wiring: if the `GiniUtilites`
     target loses `resources: [.process("Resources")]` in either
     `Package.swift` or `Package-release.swift`, `UIImage(named:in:with:)`
     silently returns nil and the badge renders blank in production.
     */
    @Test("The badge image loads from the GiniUtilites .module bundle")
    func imageLoadsFromModuleBundle() {
        let view = PoweredByGiniBadgeView()
        let imageView = view.subviews.compactMap { $0 as? UIImageView }.first

        #expect(imageView?.image != nil,
                "Expected the poweredByGiniBadge PDF to be loaded from the GiniUtilites module bundle")
    }
}
