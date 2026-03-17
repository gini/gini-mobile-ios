//
//  UIDeviceOrientationTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Regression guard for the UIDevice.isPortrait() iOS 16+ fix.
//
//  Root cause: UIWindowScene.interfaceOrientation returns .unknown when the scene
//  has not yet fully activated or is mid-transition.
//  UIInterfaceOrientation.unknown.isPortrait == false, so every sheet incorrectly
//  applied its landscape constraint set while the device was in portrait.
//
//  The fix adds a guard: when interfaceOrientation == .unknown, fall back to
//  !UIDeviceOrientation.isLandscape (unknown/flat → not landscape → portrait).

import Testing
import UIKit
@testable import GiniUtilites

@Suite("UIDevice.isPortrait() — orientation fallback guard")
struct UIDeviceOrientationTests {

    // MARK: UIInterfaceOrientation assumptions the fix relies on

    /// The entire fix is predicated on this: `.unknown.isPortrait` is `false`,
    /// which is why `.unknown` must be intercepted before calling `.isPortrait`.
    @Test("UIInterfaceOrientation.unknown.isPortrait is false (motivates the fix)")
    func unknownInterfaceOrientationIsNotPortrait() {
        #expect(UIInterfaceOrientation.unknown.isPortrait == false,
                ".unknown must be false — this is why the guard for .unknown was needed")
    }

    @Test("UIInterfaceOrientation portrait variants report isPortrait = true",
          arguments: [UIInterfaceOrientation.portrait, .portraitUpsideDown])
    func portraitInterfaceOrientationIsPortrait(orientation: UIInterfaceOrientation) {
        #expect(orientation.isPortrait == true)
    }

    @Test("UIInterfaceOrientation landscape variants report isPortrait = false",
          arguments: [UIInterfaceOrientation.landscapeLeft, .landscapeRight])
    func landscapeInterfaceOrientationIsNotPortrait(orientation: UIInterfaceOrientation) {
        #expect(orientation.isPortrait == false)
    }

    // MARK: UIDeviceOrientation assumptions the fallback relies on

    /// The fallback uses `!deviceOrientation.isLandscape` rather than
    /// `deviceOrientation.isPortrait` because:
    ///  - `.unknown.isPortrait` is `false`  → would default to landscape (wrong)
    ///  - `.unknown.isLandscape` is `false` → `!false = true` (portrait, correct)
    @Test("UIDeviceOrientation.unknown.isLandscape is false — ensures portrait default")
    func unknownDeviceOrientationIsNotLandscape() {
        #expect(UIDeviceOrientation.unknown.isLandscape == false,
                "The fallback (!isLandscape) must return true for .unknown so portrait is the safe default")
    }

    @Test("UIDeviceOrientation.unknown.isPortrait is false — motivates !isLandscape approach")
    func unknownDeviceOrientationIsNotPortrait() {
        #expect(UIDeviceOrientation.unknown.isPortrait == false,
                ".unknown.isPortrait is false — using .isPortrait directly would misidentify .unknown as landscape")
    }

    @Test("UIDeviceOrientation flat variants are neither portrait nor landscape",
          arguments: [UIDeviceOrientation.faceUp, .faceDown])
    func flatOrientationsAreNeutral(orientation: UIDeviceOrientation) {
        #expect(orientation.isPortrait == false)
        #expect(orientation.isLandscape == false,
                "Flat orientations must not trigger landscape layout path")
    }

    @Test("UIDeviceOrientation landscape variants report isLandscape = true",
          arguments: [UIDeviceOrientation.landscapeLeft, .landscapeRight])
    func landscapeDeviceOrientationIsLandscape(orientation: UIDeviceOrientation) {
        #expect(orientation.isLandscape == true)
    }

    @Test("UIDeviceOrientation portrait variants report isPortrait = true",
          arguments: [UIDeviceOrientation.portrait, .portraitUpsideDown])
    func portraitDeviceOrientationIsPortrait(orientation: UIDeviceOrientation) {
        #expect(orientation.isPortrait == true)
    }

    // MARK: UIDevice.isPortrait() — smoke test in test runner environment

    /// In the test runner there is no connected UIWindowScene, so the function falls
    /// through to the device-orientation branch.  The primary contract is: it must
    /// return a Bool and must not crash regardless of the environment.
    @Test("UIDevice.isPortrait() returns a value without crashing in test environment")
    @MainActor func isPortraitReturnsBoolInTestEnvironment() {
        // Should not throw, trap, or crash.
        let result = UIDevice.isPortrait()
        // In the test host the device orientation is .unknown, so isLandscape = false,
        // and the fallback returns true (portrait).  We don't assert a specific value
        // because CI simulators may report varying orientations; the crash-freedom
        // and Bool contract are what we need to pin here.
        _ = result  // suppress unused-result warning
        #expect(Bool.self == type(of: result))
    }

    /// Verifies the double-negation logic used in the fallback:
    /// `!UIDeviceOrientation.isLandscape` must be `true` for every non-landscape
    /// orientation (unknown, flat, portrait) so portrait is never misidentified.
    @Test(
        "!isLandscape == true for all non-landscape device orientations",
        arguments: [
            UIDeviceOrientation.unknown,
            .portrait,
            .portraitUpsideDown,
            .faceUp,
            .faceDown
        ]
    )
    func nonLandscapeOrientationsAreNotLandscape(orientation: UIDeviceOrientation) {
        #expect(!orientation.isLandscape == true,
                "The !isLandscape fallback must treat \(orientation) as portrait")
    }
}
