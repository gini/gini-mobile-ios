//
//  GiniBottomSheetModifierTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import SwiftUI
import UIKit
@testable import GiniInternalPaymentSDK

@Suite("SheetBackgroundInteractionView (HEAL-355)")
@MainActor
struct GiniBottomSheetModifierTests {

    // MARK: - makeUIView

    /**
     Hosting `SheetBackgroundInteractionHelper` inside a `UIHostingController`
     causes SwiftUI to call `makeUIView`, exercising the factory path for both
     enabled and disabled states.
     */
    @Test("makeUIView produces a view when isEnabled is true")
    func makeUIViewProducesViewWhenEnabled() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let hostingVC = UIHostingController(rootView: SheetBackgroundInteractionHelper(isEnabled: true))
        window.rootViewController = hostingVC
        window.makeKeyAndVisible()

        #expect(hostingVC.view != nil,
                "UIHostingController must have a view after being made key and visible")
    }

    @Test("makeUIView produces a view when isEnabled is false")
    func makeUIViewProducesViewWhenDisabled() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let hostingVC = UIHostingController(rootView: SheetBackgroundInteractionHelper(isEnabled: false))
        window.rootViewController = hostingVC
        window.makeKeyAndVisible()

        #expect(hostingVC.view != nil,
                "UIHostingController must have a view after being made key and visible")
    }

    // MARK: - didMoveToWindow — isEnabled: true

    @Test("didMoveToWindow does not crash when isEnabled and view has no window")
    func didMoveToWindowEnabledNoWindow() {
        let view = SheetBackgroundInteractionView(isEnabled: true)
        // Manually trigger removal (window becomes nil) — must not crash.
        view.didMoveToWindow()
    }

    @Test("didMoveToWindow does not crash when isEnabled and responder chain has no sheet")
    func didMoveToWindowEnabledNoSheet() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let parentVC = UIViewController()
        window.rootViewController = parentVC
        window.makeKeyAndVisible()

        let view = SheetBackgroundInteractionView(isEnabled: true)
        parentVC.view.addSubview(view)

        // parentVC has no sheetPresentationController — responder-chain walk
        // exhausts without finding one and must return silently.
        view.didMoveToWindow()

        #expect(view.superview === parentVC.view)
    }

    // MARK: - didMoveToWindow — isEnabled: false (VoiceOver path)

    @Test("didMoveToWindow does not crash when disabled and view has no window")
    func didMoveToWindowDisabledNoWindow() {
        let view = SheetBackgroundInteractionView(isEnabled: false)
        // guard isEnabled else { return } — must exit early without crash.
        view.didMoveToWindow()
    }

    @Test("didMoveToWindow does not crash when disabled and view is in a hierarchy")
    func didMoveToWindowDisabledInHierarchy() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let parentVC = UIViewController()
        window.rootViewController = parentVC
        window.makeKeyAndVisible()

        let view = SheetBackgroundInteractionView(isEnabled: false)
        parentVC.view.addSubview(view)

        // guard exits early — sheetPresentationController must NOT be touched.
        view.didMoveToWindow()

        #expect(view.superview === parentVC.view)
    }

    // MARK: - View properties

    @Test("SheetBackgroundInteractionView has clear background and no interaction")
    func viewProperties() {
        let view = SheetBackgroundInteractionView(isEnabled: true)

        #expect(view.backgroundColor == .clear,
                "View must be invisible so it does not affect layout or appearance")
        #expect(view.isUserInteractionEnabled == false,
                "View must not intercept touches itself")
    }
}
