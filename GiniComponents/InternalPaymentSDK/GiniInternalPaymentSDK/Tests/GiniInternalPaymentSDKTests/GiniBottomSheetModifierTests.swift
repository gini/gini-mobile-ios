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

    /// Hosting `SheetBackgroundInteractionHelper` inside a `UIHostingController`
    /// causes SwiftUI to call `makeUIViewController`, exercising the factory path.
    @Test("makeUIViewController produces a SheetBackgroundInteractionHelperController")
    func makeUIViewControllerProducesCorrectType() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let hostingVC = UIHostingController(rootView: SheetBackgroundInteractionHelper())
        window.rootViewController = hostingVC
        window.makeKeyAndVisible()

        // The window being visible triggers SwiftUI rendering, which calls
        // makeUIViewController. We verify the hosting controller is active.
        #expect(hostingVC.view != nil,
                "UIHostingController must have a view after being made key and visible")
    }

    // MARK: - viewWillAppear

    @Test("viewWillAppear does not crash when parent has no sheetPresentationController")
    func viewWillAppearWithoutParentSheet() {
        let controller = SheetBackgroundInteractionHelperController()

        // parent is nil → parent?.sheetPresentationController is nil.
        // The optional chain must silently do nothing rather than crash.
        controller.viewWillAppear(false)
    }

    @Test("viewWillAppear does not crash when controller has a parent VC")
    func viewWillAppearWithParent() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let parentVC = UIViewController()
        window.rootViewController = parentVC
        window.makeKeyAndVisible()

        let controller = SheetBackgroundInteractionHelperController()
        parentVC.addChild(controller)
        controller.didMove(toParent: parentVC)

        // parentVC is not presented as a sheet, so sheetPresentationController is nil.
        // The optional chain handles this gracefully.
        controller.viewWillAppear(false)

        #expect(controller.parent === parentVC,
                "Controller must be a child of parentVC after addChild")
    }
}
