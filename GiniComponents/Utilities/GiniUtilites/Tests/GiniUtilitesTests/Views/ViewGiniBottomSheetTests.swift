//
//  ViewGiniBottomSheetTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import Testing
import UIKit
@testable import GiniUtilites

/**
 Compile-time smoke tests for the public API shape. Runtime sheet
 presentation is Apple's and is verified via previews + manual QA.
 */
@Suite("View+GiniBottomSheet — public API shape")
struct ViewGiniBottomSheetTests {

    @Test("Modifier is available on View with isPresented and content")
    func modifierTakesIsPresentedAndContent() {
        let isPresented = Binding<Bool>.constant(false)
        _ = EmptyView().giniBottomSheet(isPresented: isPresented) {
            Text("sheet content")
        }
    }

    @Test("Modifier accepts an optional onDismiss callback")
    func modifierAcceptsOnDismiss() {
        let isPresented = Binding<Bool>.constant(false)
        _ = EmptyView().giniBottomSheet(isPresented: isPresented,
                                        onDismiss: { }) {
            Text("sheet content")
        }
    }

    @Test("Modifier defaults onDismiss to nil when omitted")
    func modifierDefaultsOnDismissToNil() {
        let isPresented = Binding<Bool>.constant(false)
        _ = EmptyView().giniBottomSheet(isPresented: isPresented) {
            Color.clear
        }
    }
}

/**
 Renders a host view with `.giniBottomSheet` applied in a window so
 SwiftUI evaluates the modifier's body and the `detent` computed
 property. Exercises both the non-accessibility and the accessibility
 `dynamicTypeSize` branches.
 */
@Suite("View+GiniBottomSheet — rendering branches")
@MainActor
struct ViewGiniBottomSheetRenderingTests {

    @Test("Host renders with isPresented false (detent set but sheet not shown)")
    func rendersIsPresentedFalse() {
        renderAndLayout(
            Color.clear.giniBottomSheet(isPresented: .constant(false)) {
                Text("sheet")
            }
        )
    }

    @Test("Host renders at an accessibility Dynamic Type size (.large detent branch)")
    func rendersAtAccessibilitySize() {
        renderAndLayout(
            Color.clear
                .giniBottomSheet(isPresented: .constant(false)) {
                    Text("sheet")
                }
                .environment(\.dynamicTypeSize, .accessibility3)
        )
    }

    @Test("Host renders with isPresented true so SwiftUI executes the sheet content closure")
    func rendersIsPresentedTrue() {
        renderAndLayout(
            Color.clear.giniBottomSheet(isPresented: .constant(true),
                                        onDismiss: { }) {
                Text("sheet content")
            }
        )
    }

    @Test("Host renders with isPresented true at an accessibility size so both branches execute")
    func rendersIsPresentedTrueAtAccessibilitySize() {
        renderAndLayout(
            Color.clear
                .giniBottomSheet(isPresented: .constant(true)) {
                    Text("sheet content")
                }
                .environment(\.dynamicTypeSize, .accessibility3)
        )
    }

    private func renderAndLayout(_ view: some View) {
        let hosting = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}
