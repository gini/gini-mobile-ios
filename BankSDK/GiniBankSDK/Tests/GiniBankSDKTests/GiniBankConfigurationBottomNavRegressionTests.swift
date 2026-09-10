//
//  GiniBankConfigurationBottomNavRegressionTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniBankSDK

/**
 Asserts that the bottom-navigation-bar adapter surface has not been
 re-introduced on `GiniBankConfiguration`.
 */
@Suite("GiniBankConfiguration — no bottom-nav adapter surface")
struct GiniBankConfigurationBottomNavRegressionTests {

    @Test func giniBankConfigurationHasNoBottomNavigationBarSurface() {
        let mirror = Mirror(reflecting: GiniBankConfiguration())
        for child in mirror.children {
            guard let name = child.label else { continue }
            #expect(!name.lowercased().contains("bottomnavigation"))
            #expect(!name.hasSuffix("NavigationBarBottomAdapter"))
        }
    }
}
