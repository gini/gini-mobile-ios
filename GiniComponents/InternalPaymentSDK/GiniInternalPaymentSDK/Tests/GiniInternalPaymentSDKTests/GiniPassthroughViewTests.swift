//
//  GiniPassthroughViewTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.

import Testing
import UIKit
@testable import GiniInternalPaymentSDK

@Suite("GiniPassthroughView — hitTest regression guard (HEAL-336)")
@MainActor
struct GiniPassthroughViewTests {

    // MARK: - Pass-through

    /// Tapping on the transparent background of the passthrough view must return
    /// `nil` so the touch falls through to the main window below the overlay.
    @Test("Returns nil when the hit view is the passthrough view itself")
    func hitTestReturnsNilForBackground() {
        let view = GiniPassthroughView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let result = view.hitTest(CGPoint(x: 100, y: 100), with: nil)

        #expect(result == nil,
                "hitTest must return nil for the background so touches fall through to the main window")
    }

    // MARK: - Subview forwarding

    /// Tapping on a subview (e.g. a presented bottom sheet) must return that
    /// subview so the touch is delivered normally to the sheet's controls.
    @Test("Returns the subview when a subview is hit")
    func hitTestReturnsSubviewWhenHit() {
        let view = GiniPassthroughView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let subview = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        view.addSubview(subview)

        let result = view.hitTest(CGPoint(x: 100, y: 100), with: nil)

        #expect(result === subview,
                "hitTest must return the subview so touches on presented content are handled normally")
    }

    /// A point outside all subviews but still inside the passthrough view must
    /// still return nil, confirming the background-passthrough behaviour holds
    /// even when subviews are present.
    @Test("Returns nil for background area when subviews are present")
    func hitTestReturnsNilForBackgroundWhenSubviewsPresent() {
        let view = GiniPassthroughView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let subview = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        view.addSubview(subview)

        let result = view.hitTest(CGPoint(x: 10, y: 10), with: nil)

        #expect(result == nil,
                "hitTest must return nil for background areas even when subviews are present")
    }
}
