//
//  GiniConfigurationBottomNavRegressionTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniCaptureSDK

/**
 Asserts that the bottom-navigation-bar adapter surface has not been
 re-introduced on `GiniConfiguration`.
 */
@Suite("GiniConfiguration — no bottom-nav adapter surface")
struct GiniConfigurationBottomNavRegressionTests {

    @Test func giniConfigurationHasNoBottomNavigationBarSurface() {
        let mirror = Mirror(reflecting: GiniConfiguration())
        for child in mirror.children {
            guard let name = child.label else { continue }
            #expect(!name.lowercased().contains("bottomnavigation"))
            #expect(!name.hasSuffix("NavigationBarBottomAdapter"))
        }
    }
}
