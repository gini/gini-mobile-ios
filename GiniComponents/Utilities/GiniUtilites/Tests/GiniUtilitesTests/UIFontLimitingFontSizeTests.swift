//
//  UIFontLimitingFontSizeTests.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniUtilites

final class UIFontLimitingFontSizeTests: XCTestCase {

    private let baseFont = UIFont.systemFont(ofSize: 24)
    private let limit: CGFloat = 20

    // MARK: - Non-accessibility category

    func testReturnsOriginalFontWhenNotAccessibilityCategory() {
        UITraitCollection.current = UITraitCollection(preferredContentSizeCategory: .large)

        let result = baseFont.limitingFontSize(to: limit)

        XCTAssertEqual(result.pointSize, baseFont.pointSize)
    }

    // MARK: - Accessibility category, font within limit

    func testReturnsOriginalFontWhenPointSizeWithinLimitAndAccessibility() {
        UITraitCollection.current = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
        let smallFont = UIFont.systemFont(ofSize: 16)

        let result = smallFont.limitingFontSize(to: limit)

        XCTAssertEqual(result.pointSize, smallFont.pointSize)
    }

    // MARK: - Accessibility category, font exceeds limit

    func testCapsPointSizeWhenExceedsLimitAndAccessibility() {
        UITraitCollection.current = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)

        let result = baseFont.limitingFontSize(to: limit)

        XCTAssertEqual(result.pointSize, limit)
    }

    func testCapsPointSizeAtExactLimitWhenAccessibility() {
        UITraitCollection.current = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
        let exactFont = UIFont.systemFont(ofSize: limit)

        let result = exactFont.limitingFontSize(to: limit)

        XCTAssertEqual(result.pointSize, limit)
    }
}
