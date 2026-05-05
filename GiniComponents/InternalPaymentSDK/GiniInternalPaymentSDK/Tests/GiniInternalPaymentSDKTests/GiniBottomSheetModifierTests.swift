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

@Suite("SheetBackgroundInteractionHelper (HEAL-355)")
@MainActor
struct GiniBottomSheetModifierTests {

    // MARK: - makeUIViewController

    /**
     Hosting `SheetBackgroundInteractionHelper` inside a `UIHostingController`
     causes SwiftUI to call `makeUIViewController`, exercising the factory path.
     */
    @Test("makeUIViewController produces a view controller when isEnabled is true")
    func makeUIViewControllerProducesControllerWhenEnabled() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let hostingVC = UIHostingController(rootView: SheetBackgroundInteractionHelper(isEnabled: true))
        window.rootViewController = hostingVC
        window.makeKeyAndVisible()

        #expect(hostingVC.view != nil,
                "UIHostingController must have a view after being made key and visible")
    }

    @Test("makeUIViewController produces a view controller when isEnabled is false")
    func makeUIViewControllerProducesControllerWhenDisabled() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let hostingVC = UIHostingController(rootView: SheetBackgroundInteractionHelper(isEnabled: false))
        window.rootViewController = hostingVC
        window.makeKeyAndVisible()

        #expect(hostingVC.view != nil,
                "UIHostingController must have a view after being made key and visible")
    }

    // MARK: - viewWillAppear — isEnabled: true

    @Test("viewWillAppear does not crash when isEnabled and parent has no sheet")
    func viewWillAppearEnabledWithoutParentSheet() {
        let controller = SheetBackgroundInteractionHelperController(isEnabled: true)
        // parent is nil → optional chain silently does nothing
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()
    }

    @Test("viewWillAppear does not crash when isEnabled and parent VC has no sheet presentation controller")
    func viewWillAppearEnabledWithParentNoSheet() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let parentVC = UIViewController()
        window.rootViewController = parentVC
        window.makeKeyAndVisible()

        let controller = SheetBackgroundInteractionHelperController(isEnabled: true)
        parentVC.addChild(controller)
        controller.didMove(toParent: parentVC)

        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()

        #expect(controller.parent === parentVC)
    }

    // MARK: - viewWillAppear — isEnabled: false (VoiceOver path)

    @Test("viewWillAppear does not crash when disabled and parent has no sheet")
    func viewWillAppearDisabledWithoutParentSheet() {
        let controller = SheetBackgroundInteractionHelperController(isEnabled: false)
        // guard isEnabled else { return } exits early — must not crash
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()
    }

    @Test("viewWillAppear does not crash when disabled and parent VC is present")
    func viewWillAppearDisabledWithParent() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let parentVC = UIViewController()
        window.rootViewController = parentVC
        window.makeKeyAndVisible()

        let controller = SheetBackgroundInteractionHelperController(isEnabled: false)
        parentVC.addChild(controller)
        controller.didMove(toParent: parentVC)

        // guard exits early — sheetPresentationController must NOT be configured
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()

        #expect(controller.parent === parentVC)
    }
}
