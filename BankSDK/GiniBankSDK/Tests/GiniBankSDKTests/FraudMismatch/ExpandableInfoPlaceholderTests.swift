//
//  ExpandableInfoPlaceholderTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Testing
@testable import GiniBankSDK

@Suite("ExpandableInfoPlaceholder")
@MainActor
struct ExpandableInfoPlaceholderTests {

    @Test("renders collapsed without crashing")
    func rendersCollapsed() {
        var isExpanded = false
        let binding = Binding<Bool>(get: { isExpanded }, set: { isExpanded = $0 })
        renderInWindow(ExpandableInfoPlaceholder(title: "Title",
                                                 message: "Body text",
                                                 icon: Image(systemName: "shield"),
                                                 isExpanded: binding))
    }

    @Test("renders expanded without crashing")
    func rendersExpanded() {
        var isExpanded = true
        let binding = Binding<Bool>(get: { isExpanded }, set: { isExpanded = $0 })
        renderInWindow(ExpandableInfoPlaceholder(title: "Title",
                                                 message: "Body text",
                                                 icon: Image(systemName: "shield"),
                                                 isExpanded: binding))
    }

    private func renderInWindow<Content: View>(_ view: Content) {
        let hosting = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}
