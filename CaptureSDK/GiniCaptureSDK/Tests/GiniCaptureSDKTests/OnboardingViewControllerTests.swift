//
//  OnboardingViewControllerTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
import UIKit
@testable import GiniCaptureSDK

/**
 Asserts that the onboarding screen's bottom-navigation adapter surface has
 not been re-introduced, and that the surviving skip control is the top-nav
 `skipButton` — mirrors the R12 regression pattern but scoped to
 `OnboardingViewController` outlets and layout.
 */
@MainActor
@Suite("OnboardingViewController — no bottom-nav adapter surface")
struct OnboardingViewControllerTests {

    /**
     `nextButton?.isHidden = false` was hoisted out of the orientation
     if/else in `viewDidLayoutSubviews`. On iPhone portrait the next
     button must render visible after layout — regardless of which
     orientation branch runs.
     */
    @Test func nextButtonIsHiddenFalseAfterLayoutInPortrait() {
        let vc = OnboardingViewController()
        vc.loadViewIfNeeded()
        vc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        /// On iPad the hoisted branch is not entered (guard `isIphone`), so
        /// the assertion only applies on iPhone. On iPad the button just
        /// keeps its default xib visibility.
        if UIDevice.current.isIphone {
            #expect(vc.nextButton?.isHidden == false)
        }
    }

    /**
     Companion to the portrait case — the landscape branch of the collapsed
     `viewDidLayoutSubviews` must also leave `nextButton.isHidden == false`.
     `view.currentInterfaceOrientation` is derived from window geometry, so
     asserting the strict landscape branch inside a unit test would require
     a real UIWindow scene. Instead this verifies the invariant on the
     default post-layout state — the branch that actually flips
     `isHidden` was hoisted, so both orientations converge on the same
     visibility. A full landscape rotation check is deferred to the
     BrowserStack smoke suite.
     */
    @Test func nextButtonIsHiddenFalseAfterLayoutInLandscape() {
        let vc = OnboardingViewController()
        vc.loadViewIfNeeded()
        vc.view.frame = CGRect(x: 0, y: 0, width: 844, height: 390)
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        if UIDevice.current.isIphone {
            #expect(vc.nextButton?.isHidden == false)
        }
    }

    /**
     The top-nav `skipButton` (a `GiniBarButton`) is the sole skip control.
     Mirror-walk the VC and assert no stored property named
     `skipBottomBarButton` exists.
     */
    @Test func skipButtonIsTheTopNavSkipControl() {
        let vc = OnboardingViewController()
        vc.loadViewIfNeeded()

        let mirror = Mirror(reflecting: vc)
        for child in mirror.children {
            guard let name = child.label else { continue }
            /// `contains` rather than `==` because lazy stored properties
            /// surface as `$__lazy_storage_$_<name>` in the mirror.
            #expect(!name.contains("skipBottomBarButton"))
        }
    }

    /**
     Regression guard against re-introducing any bottom-navigation-bar
     property on `OnboardingViewController`. Parallels R12 but scoped to
     the onboarding VC.
     */
    @Test func noBottomNavigationBarOutletExists() {
        let vc = OnboardingViewController()
        vc.loadViewIfNeeded()

        let mirror = Mirror(reflecting: vc)
        for child in mirror.children {
            guard let name = child.label else { continue }
            #expect(!name.lowercased().contains("bottomnav"))
            #expect(!name.lowercased().contains("bottombar"))
        }
    }
}
