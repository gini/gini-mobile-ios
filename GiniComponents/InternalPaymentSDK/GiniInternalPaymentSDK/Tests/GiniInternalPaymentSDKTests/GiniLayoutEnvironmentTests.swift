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
        #expect(GiniLayoutEnvironment(verticalSizeClass: .compact).isLandscape == true, "compact vertical size class must map to landscape")
    }

    @Test("regular vertical size class is not landscape")
    func regularIsNotLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: .regular).isLandscape == false, "regular vertical size class must not be landscape")
    }

    @Test("nil vertical size class is not landscape")
    func nilIsNotLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: nil).isLandscape == false, "nil vertical size class must not be landscape")
    }
}
