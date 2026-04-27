//
//  GiniLayoutEnvironmentTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("GiniLayoutEnvironment")
struct GiniLayoutEnvironmentTests {

    @Test("compact vertical size class maps to landscape")
    func compactIsLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: .compact).isLandscape == true)
    }

    @Test("regular vertical size class is not landscape")
    func regularIsNotLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: .regular).isLandscape == false)
    }

    @Test("nil vertical size class is not landscape")
    func nilIsNotLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: nil).isLandscape == false)
    }
}
