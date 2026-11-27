//
//  GiniHeightPreferenceKeyTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import CoreGraphics
@testable import GiniUtilites

@Suite("GiniHeightPreferenceKey — SwiftUI preference-key reduction")
struct GiniHeightPreferenceKeyTests {

    @Test("defaultValue is zero so the first descendant's height wins outright")
    func defaultValueIsZero() {
        #expect(GiniHeightPreferenceKey.defaultValue == .zero)
    }

    @Test("reduce overwrites value with the next descendant's height (last-writer-wins)")
    func reduceOverwritesValueWithNextHeight() {
        var current: CGFloat = 10

        GiniHeightPreferenceKey.reduce(value: &current) { 42 }

        #expect(current == 42,
                "reduce must adopt the new descendant's value — SwiftUI calls reduce once per descendant and the last one must win.")
    }
}
