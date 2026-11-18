//
//  ViewGiniBottomSheetTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import Testing
@testable import GiniUtilites

// Suites and tests cannot be marked `@available(iOS 16.0, *)` because Swift
// Testing's macros refuse to decorate availability-marked declarations. Each
// body uses `guard #available(iOS 16.0, *) else { return }`; on CI (iOS 26.2)
// the guard always passes.

/// Compile-time smoke tests for the public API shape. Runtime sheet
/// presentation is Apple's and is verified via previews + manual QA.
@Suite("View+GiniBottomSheet — public API shape")
struct ViewGiniBottomSheetTests {

    @Test("Modifier is available on View with isPresented and content")
    func modifierTakesIsPresentedAndContent() {
        guard #available(iOS 16.0, *) else { return }
        let isPresented = Binding<Bool>.constant(false)
        _ = EmptyView().giniBottomSheet(isPresented: isPresented) {
            Text("sheet content")
        }
    }

    @Test("Modifier accepts an optional onDismiss callback")
    func modifierAcceptsOnDismiss() {
        guard #available(iOS 16.0, *) else { return }
        let isPresented = Binding<Bool>.constant(false)
        _ = EmptyView().giniBottomSheet(isPresented: isPresented,
                                        onDismiss: { }) {
            Text("sheet content")
        }
    }

    @Test("Modifier defaults onDismiss to nil when omitted")
    func modifierDefaultsOnDismissToNil() {
        guard #available(iOS 16.0, *) else { return }
        let isPresented = Binding<Bool>.constant(false)
        _ = EmptyView().giniBottomSheet(isPresented: isPresented) {
            Color.clear
        }
    }
}
