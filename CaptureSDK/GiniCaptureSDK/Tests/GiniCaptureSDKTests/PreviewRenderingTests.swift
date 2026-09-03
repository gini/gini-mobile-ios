//
//  PreviewRenderingTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Renders the `#if DEBUG` SwiftUI preview providers inside a hosted UIWindow
//  so that `GiniViewControllerPreview.makeUIViewController` and the preview
//  builder closures actually execute, and asserts on the rendered hierarchy.

import SwiftUI
import Testing
import UIKit
@testable import GiniCaptureSDK

@Suite("SwiftUI preview rendering")
@MainActor
struct PreviewRenderingTests {

    private typealias Helper = ViewHierarchyTestHelper

    // MARK: - Helpers

    /**
     Hosts the given preview content in a key window and lets the run loop
     spin briefly so `UIViewControllerRepresentable.makeUIViewController`
     runs and the embedded controller's view is attached and laid out.

     The caller must hide the window at the end of the test (`window.isHidden = true`).
     */
    private func renderPreview<Content: View>(_ content: Content) -> UIWindow {
        let hostingController = UIHostingController(rootView: content)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.layoutIfNeeded()
        /// Pump the main run loop so SwiftUI performs the representable's
        /// view-controller creation and embedding.
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        return window
    }

    /// Collects every `UIButton` in the hierarchy via depth-first traversal.
    private func allButtons(in root: UIView) -> [UIButton] {
        var buttons: [UIButton] = []
        if let button = root as? UIButton {
            buttons.append(button)
        }
        for subview in root.subviews {
            buttons.append(contentsOf: allButtons(in: subview))
        }
        return buttons
    }

    // MARK: - Tests

    @Test("Credit note warning preview renders the bottom sheet content")
    func creditNoteWarningPreviewRenders() throws {
        let window = renderPreview(CreditNoteWarningViewController_Preview.previews)
        defer { window.isHidden = true }

        let titleLabel = Helper.firstLabel(withText: CreditNoteWarningViewController.Strings.title,
                                           in: window)
        #expect(titleLabel != nil,
                "The rendered preview should contain the credit note warning title")

        /// Fire the rendered buttons so the preview's `onCancel`/`onProceed`
        /// closures execute as well (they only log to the console).
        let buttons = allButtons(in: window)
        #expect(!buttons.isEmpty, "The preview should render the Cancel and Proceed buttons")
        for button in buttons {
            Helper.tap(button)
        }
    }

    @Test("Document marked as paid preview renders the bottom sheet content")
    func documentMarkedAsPaidPreviewRenders() throws {
        let window = renderPreview(DocumentMarkedAsPaidViewController_Preview.previews)
        defer { window.isHidden = true }

        let titleLabel = Helper.firstLabel(withText: DocumentMarkedAsPaidViewController.Strings.title,
                                           in: window)
        #expect(titleLabel != nil,
                "The rendered preview should contain the document-marked-as-paid title")

        /// Fire the rendered buttons so the preview's `onCancel`/`onProceed`
        /// closures execute as well (they only log to the console).
        let buttons = allButtons(in: window)
        #expect(!buttons.isEmpty, "The preview should render the Cancel and Proceed buttons")
        for button in buttons {
            Helper.tap(button)
        }
    }
}
