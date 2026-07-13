//
//  GiniKeyboardAccessoryInstaller.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit
import GiniUtilites

/**
 A zero-size SwiftUI helper that installs a `GiniDoneAccessoryView` on the current
 first-responder `UITextField` while `isActive` is `true`.

 Use as a `.background(...)` on the SwiftUI `TextField` that owns the focus (or on any
 ancestor). The SwiftUI `TextField` continues to manage editing and `@FocusState`; this
 helper only sets `inputAccessoryView` on whichever underlying UIKit `UITextField` is
 currently first responder.

 Why this instead of a `.toolbar { ToolbarItemGroup(placement: .keyboard) }`:
 SwiftUI's keyboard toolbar is unreliable inside a `.sheet {}` on iOS 26 — after a
 portrait→landscape→portrait rotation the re-presented sheet's toolbar sometimes fails
 to re-attach, and the accessory view's height flipping empty↔populated triggers
 `_UIRemoteKeyboardPlaceholderView` constraint conflicts. UIKit's `inputAccessoryView`
 is glued to the keyboard's own window and has none of those failure modes.
 */
struct GiniKeyboardAccessoryInstaller: UIViewRepresentable {

    let isActive: Bool
    let doneTintColor: UIColor
    let onDone: () -> Void

    func makeUIView(context _: Context) -> UIView {
        UIView(frame: .zero)
    }

    func updateUIView(_: UIView, context: Context) {
        context.coordinator.apply(isActive: isActive, doneTintColor: doneTintColor, onDone: onDone)
    }

    static func dismantleUIView(_: UIView, coordinator: Coordinator) {
        coordinator.uninstallIfInstalled()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(doneTintColor: doneTintColor, onDone: onDone)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, GiniDoneAccessoryViewDelegate {

        var onDone: () -> Void
        var doneTintColor: UIColor

        /**
         The field we most recently attached to, so we can clear our accessory
         when it is no longer relevant (focus moved to a non-decimal field, view dismissed).
         */
        private weak var attachedField: UITextField?

        /**
         Cached accessory — reused on every install so we don't allocate a fresh one
         per SwiftUI update (its Done tap would target a stale delegate on iOS 17.4).
         */
         
        private var persistentAccessory: GiniDoneAccessoryView?

        /**
         Injectable for tests; defaults to walking `UIApplication.shared.connectedScenes`.
         */
        private let currentFirstResponder: () -> UITextField?

        /**
         Debounce for `apply` — cancels any pending install/uninstall from a previous
         SwiftUI update before scheduling the new one. Without this, a burst of
         `apply(isActive: true)` calls followed by `apply(isActive: false)` (which
         happens on every focus change during a SwiftUI update storm) would fire ALL
         the queued `installIfNeeded` closures AFTER the user has already moved focus
         to a different field, installing our accessory on the wrong UITextField.
         */
        private var pendingWork: DispatchWorkItem?

        init(doneTintColor: UIColor,
             onDone: @escaping () -> Void,
             currentFirstResponder: @escaping () -> UITextField? = { Coordinator.currentFirstResponderUITextField() }) {
            self.doneTintColor = doneTintColor
            self.onDone = onDone
            self.currentFirstResponder = currentFirstResponder
        }

        /**
         Deferred to the next runloop so we don't mutate first-responder state during a
         SwiftUI update pass.
         */
        func apply(isActive: Bool, doneTintColor: UIColor, onDone: @escaping () -> Void) {
            self.onDone = onDone
            self.doneTintColor = doneTintColor
            // Cancel any pending work — the LATEST apply's intent wins. Otherwise
            // stale `installIfNeeded` closures from earlier `apply(isActive: true)`
            // calls would fire after focus has moved to another field and install
            // our accessory on the wrong UITextField.
            pendingWork?.cancel()
            let work = DispatchWorkItem { [weak self] in
                guard let self else { return }
                if isActive {
                    self.installIfNeeded()
                } else {
                    self.uninstallIfInstalled()
                }
            }
            pendingWork = work
            DispatchQueue.main.async(execute: work)
        }

        func installIfNeeded() {
            guard let field = currentFirstResponder() else { return }
            // If we already have an attachedField and the current FR is a different one,
            // focus has moved between when apply(true) was queued and when it fired. Don't
            // install on the wrong field — that caused the sticky Done toolbar over the
            // alphanumeric keyboard when moving amount → IBAN.
            if let attached = attachedField, attached !== field {
                return
            }
            // Idempotent — if we already installed on this same field, keep the accessory
            // and just refresh the tint.
            if let existing = field.inputAccessoryView as? GiniDoneAccessoryView, existing.delegate === self {
                existing.setDoneTintColor(doneTintColor)
                return
            }
            let accessory = persistentAccessory ?? GiniDoneAccessoryView(tintColor: doneTintColor)
            persistentAccessory = accessory
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
            persistentAccessory = nil
        }

        func giniDoneAccessoryViewDidTapDone(_: GiniDoneAccessoryView) {
            onDone()
        }

        // MARK: - Responder-chain discovery

        static func currentFirstResponderUITextField() -> UITextField? {
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

        static func findFirstResponder(in view: UIView) -> UIResponder? {
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
