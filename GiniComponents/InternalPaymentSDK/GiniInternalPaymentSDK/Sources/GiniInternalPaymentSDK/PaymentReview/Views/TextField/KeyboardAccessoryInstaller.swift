//
//  KeyboardAccessoryInstaller.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit
import GiniUtilites

/// A zero-size SwiftUI helper that installs a `GiniDoneAccessoryView` on the current
/// first-responder `UITextField` while `isActive` is true.
///
/// Use as a `.background(...)` on the SwiftUI `TextField` that owns the focus (or on any
/// ancestor). The SwiftUI `TextField` continues to manage editing and `@FocusState`;
/// this helper only sets `inputAccessoryView` on whichever underlying UIKit `UITextField` is
/// currently first responder.
///
/// Why this instead of a `.toolbar { ToolbarItemGroup(placement: .keyboard) }`:
/// SwiftUI's keyboard toolbar is unreliable inside a `.sheet {}` on iOS 26 — after a
/// portrait→landscape→portrait rotation the re-presented sheet's toolbar sometimes fails
/// to re-attach, and the accessory view's height flipping empty↔populated triggers
/// `_UIRemoteKeyboardPlaceholderView` constraint conflicts. UIKit's `inputAccessoryView`
/// is glued to the keyboard's own window and has none of those failure modes.
struct KeyboardAccessoryInstaller: UIViewRepresentable {

    let isActive: Bool
    let doneTintColor: UIColor
    let onDone: () -> Void

    func makeUIView(context: Context) -> UIView {
        UIView(frame: .zero)
    }

    func updateUIView(_ view: UIView, context: Context) {
        // Refresh the coordinator's captured callback so the Done tap always dispatches
        // through the current view struct's closure.
        context.coordinator.onDone = onDone
        context.coordinator.doneTintColor = doneTintColor

        // Defer to the next runloop so we don't mutate first-responder state during a
        // SwiftUI update pass. By the time this fires, the SwiftUI TextField the user
        // just focused has become first responder.
        let shouldInstall = isActive
        DispatchQueue.main.async {
            if shouldInstall {
                context.coordinator.installIfNeeded()
            } else {
                context.coordinator.uninstallIfInstalled()
            }
        }
    }

    static func dismantleUIView(_ view: UIView, coordinator: Coordinator) {
        coordinator.uninstallIfInstalled()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(doneTintColor: doneTintColor, onDone: onDone)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, GiniDoneAccessoryViewDelegate {

        var onDone: () -> Void
        var doneTintColor: UIColor

        /// The field we most recently attached to, so we can revert its `inputAccessoryView`
        /// when the accessory is no longer relevant (focus moved to a non-decimal field, view dismissed).
        private weak var attachedField: UITextField?

        init(doneTintColor: UIColor, onDone: @escaping () -> Void) {
            self.doneTintColor = doneTintColor
            self.onDone = onDone
        }

        func installIfNeeded() {
            guard let field = Self.currentFirstResponderUITextField() else { return }
            // Idempotent — if we already installed on this same field, keep the accessory and
            // just refresh the tint.
            if let existing = field.inputAccessoryView as? GiniDoneAccessoryView, existing.delegate === self {
                existing.setDoneTintColor(doneTintColor)
                return
            }
            let accessory = GiniDoneAccessoryView(tintColor: doneTintColor)
            accessory.delegate = self
            field.inputAccessoryView = accessory
            field.reloadInputViews()
            attachedField = field
        }

        func uninstallIfInstalled() {
            guard let field = attachedField else { return }
            if let existing = field.inputAccessoryView as? GiniDoneAccessoryView, existing.delegate === self {
                field.inputAccessoryView = nil
                // Only reload if the field is still first responder; otherwise it's a no-op
                // that can cause a keyboard flash on some iOS versions.
                if field.isFirstResponder {
                    field.reloadInputViews()
                }
            }
            attachedField = nil
        }

        func giniDoneAccessoryViewDidTapDone(_ view: GiniDoneAccessoryView) {
            onDone()
        }

        // MARK: - Responder-chain discovery

        private static func currentFirstResponderUITextField() -> UITextField? {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                for window in windowScene.windows where window.isKeyWindow {
                    if let responder = findFirstResponder(in: window) as? UITextField {
                        return responder
                    }
                }
            }
            return nil
        }

        private static func findFirstResponder(in view: UIView) -> UIResponder? {
            if view.isFirstResponder { return view }
            for subview in view.subviews {
                if let responder = findFirstResponder(in: subview) {
                    return responder
                }
            }
            return nil
        }
    }
}
