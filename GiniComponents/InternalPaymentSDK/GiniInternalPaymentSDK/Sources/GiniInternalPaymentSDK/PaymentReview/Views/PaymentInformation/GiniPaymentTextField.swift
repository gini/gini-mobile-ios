//
//  GiniPaymentTextField.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit
import GiniUtilites

/**
 UIKit-backed text field used by every payment-review input (recipient, IBAN, amount,
 payment purpose).

 The SwiftUI wrapper reproduces the chrome that `GiniTextFieldStyle` provides for the
 stock SwiftUI `TextField` (title, border, error message, locked icon) so the field is
 visually indistinguishable from the previous implementation. The underlying input is a
 UIKit `UITextField` wrapped in `GiniPaymentUITextFieldRepresentable`, which will grow
 additional capabilities (first-responder bridging, shared input accessory view, return
 key handling) in subsequent commits.
 */
struct GiniPaymentTextField: View {

    @Binding var text: String
    @Binding var isFocused: Bool

    let title: String
    let state: GiniTextFieldState
    let errorMessage: String?
    let normalConfiguration: TextFieldConfiguration
    let focusedConfiguration: TextFieldConfiguration
    let errorConfiguration: TextFieldConfiguration
    let keyboardType: UIKeyboardType
    let autocapitalizationType: UITextAutocapitalizationType
    let returnKeyType: UIReturnKeyType
    let isDisabled: Bool
    let lockedIcon: Image?

    private var currentConfiguration: TextFieldConfiguration {
        switch state {
        case .error: return errorConfiguration
        case .focused: return focusedConfiguration
        case .normal: return normalConfiguration
        }
    }

    private var shouldAnimate: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }

    var body: some View {
        let fieldAnimation = shouldAnimate
            ? Animation.easeInOut(duration: Constants.animationDuration)
            : nil

        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            VStack(spacing: Constants.titleSpacing) {
                titleView

                GiniPaymentUITextFieldRepresentable(text: $text,
                                                    isFocused: $isFocused,
                                                    font: currentConfiguration.textFont,
                                                    textColor: currentConfiguration.textColor,
                                                    keyboardType: keyboardType,
                                                    autocapitalizationType: autocapitalizationType,
                                                    returnKeyType: returnKeyType,
                                                    isEnabled: !isDisabled)
                    .frame(minHeight: Constants.textFieldHeight)
                    .accessibilityLabel(title)
                    .accessibilityHintIfPresent(state == .error ? errorMessage : nil)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.verticalPadding)
            .background(Color(currentConfiguration.backgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius)
                    .stroke(Color(currentConfiguration.borderColor),
                            lineWidth: currentConfiguration.borderWidth)
            }

            if state == .error, let errorMessage, !errorMessage.isEmpty {
                errorMessageView(errorMessage)
            }
        }
        .animation(fieldAnimation, value: state)
    }

    @ViewBuilder
    private var titleView: some View {
        HStack {
            Text(title)
                .font(Font(giniFont: currentConfiguration.textFont))
                .foregroundStyle(Color(currentConfiguration.placeholderForegroundColor))

            if let lockedIcon {
                lockedIcon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.lockedIconSize.width,
                           height: Constants.lockedIconSize.height)
                    .accessibilityHidden(true)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func errorMessageView(_ errorMessage: String) -> some View {
        Text(errorMessage)
            .foregroundStyle(Color(errorConfiguration.borderColor))
            .font(Font(giniFont: errorConfiguration.textFont))
            .padding(.horizontal, Constants.errorMessageHorizontalPadding)
            .multilineTextAlignment(.leading)
            .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal: .opacity))
            .accessibilityHidden(true)
            .animation(shouldAnimate ? Animation.easeInOut(duration: Constants.animationDuration) : nil,
                       value: errorMessage)
    }

    private enum Constants {
        static let verticalSpacing = 4.0
        static let horizontalPadding = 8.0
        static let verticalPadding = 8.0
        static let textFieldHeight = 30.0
        static let titleSpacing = 0.0
        static let errorMessageHorizontalPadding = 8.0
        static let lockedIconSize = CGSize(width: 12, height: 12)
        static let animationDuration = 0.25
    }
}

// MARK: - UIViewRepresentable

/**
 UITextField bridge for the payment-review fields. Text is synced through a target-action
 on `.editingChanged`. Focus bridging, shared accessory view wiring, and return-key
 handling are introduced in later commits.
 */
private struct GiniPaymentUITextFieldRepresentable: UIViewRepresentable {

    @Binding var text: String
    @Binding var isFocused: Bool

    let font: UIFont
    let textColor: UIColor
    let keyboardType: UIKeyboardType
    let autocapitalizationType: UITextAutocapitalizationType
    let returnKeyType: UIReturnKeyType
    let isEnabled: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.delegate = context.coordinator
        field.addTarget(context.coordinator,
                        action: #selector(Coordinator.editingChanged(_:)),
                        for: .editingChanged)
        field.font = font
        field.textColor = textColor
        field.keyboardType = keyboardType
        field.autocapitalizationType = autocapitalizationType
        field.returnKeyType = returnKeyType
        field.isEnabled = isEnabled
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self

        if uiView.text != text {
            uiView.text = text
        }
        if uiView.font != font { uiView.font = font }
        if uiView.textColor != textColor { uiView.textColor = textColor }
        if uiView.keyboardType != keyboardType { uiView.keyboardType = keyboardType }
        if uiView.autocapitalizationType != autocapitalizationType {
            uiView.autocapitalizationType = autocapitalizationType
        }
        if uiView.returnKeyType != returnKeyType { uiView.returnKeyType = returnKeyType }
        if uiView.isEnabled != isEnabled { uiView.isEnabled = isEnabled }

        // Bridge focus binding → UITextField first responder state.
        //
        // Sync `becomeFirstResponder` matches the timing UIKit sees on a direct tap so
        // programmatic focus changes (e.g. prev/next chevrons) don't visibly bounce the
        // sheet detent. It's wrapped in `performProgrammaticFocusChange` so the delegate
        // callbacks it triggers know they're firing from our own call and skip their
        // SwiftUI state writes — otherwise we'd cycle by mutating `parent.isFocused`
        // during SwiftUI's own update pass. If the sync attempt returns false (window
        // not attached yet), the retry Task handles it.
        if isFocused, !uiView.isFirstResponder, isEnabled {
            context.coordinator.performProgrammaticFocusChange {
                uiView.window != nil
                    && !uiView.isHidden
                    && uiView.becomeFirstResponder()
            } fallback: {
                context.coordinator.attemptBecomeFirstResponder(uiView)
            }
        } else if !isFocused, uiView.isFirstResponder {
            context.coordinator.cancelPendingFocusAttempt()
            context.coordinator.performProgrammaticFocusChange {
                uiView.resignFirstResponder()
                return true
            } fallback: { }
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {

        var parent: GiniPaymentUITextFieldRepresentable

        private var focusAttemptTask: Task<Void, Never>?

        /**
         Non-zero while we're inside a first-responder change we initiated ourselves
         (from `updateUIView`). While set, the UITextField delegate methods skip their
         SwiftUI state writes — the state that triggered our call is already correct,
         and writing again during SwiftUI's own update pass would create an
         AttributeGraph cycle and the "Modifying state during view update" warning.
         */
        private var programmaticFocusDepth = 0

        init(_ parent: GiniPaymentUITextFieldRepresentable) {
            self.parent = parent
        }

        deinit {
            focusAttemptTask?.cancel()
        }

        /**
         Runs `attempt` while marking any UITextField delegate callbacks it triggers as
         coming from us. If `attempt` returns false, `fallback` runs *after* the guard
         so it can schedule further work normally (e.g. the retry Task).
         */
        func performProgrammaticFocusChange(_ attempt: () -> Bool, fallback: () -> Void) {
            programmaticFocusDepth += 1
            let succeeded = attempt()
            programmaticFocusDepth -= 1
            if !succeeded {
                fallback()
            }
        }

        private var isDelegateFromProgrammaticChange: Bool {
            programmaticFocusDepth > 0
        }

        /**
         Retries `becomeFirstResponder` until the field is attached to a window (or the
         `isFocused` binding flips to `false`). Handles the rotation case where
         `updateUIView` runs before SwiftUI has finished attaching the recreated view.
         */
        func attemptBecomeFirstResponder(_ uiView: UITextField) {
            focusAttemptTask?.cancel()
            focusAttemptTask = Task { @MainActor [weak self, weak uiView] in
                for _ in 0..<Constants.focusRetryCount {
                    guard !Task.isCancelled,
                          let uiView,
                          let self,
                          self.parent.isFocused
                    else { return }
                    if uiView.window != nil,
                       uiView.isEnabled,
                       !uiView.isHidden,
                       uiView.becomeFirstResponder() {
                        return
                    }
                    try? await Task.sleep(for: .milliseconds(Constants.focusRetryIntervalMs))
                }
            }
        }

        func cancelPendingFocusAttempt() {
            focusAttemptTask?.cancel()
            focusAttemptTask = nil
        }

        @objc func editingChanged(_ textField: UITextField) {
            let newValue = textField.text ?? ""
            if parent.text != newValue {
                parent.text = newValue
            }
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Skip when *we* triggered this become. `focusedField` is already correct
            // in that case, and writing again during SwiftUI's update pass would cycle.
            // Only update when UIKit initiated the become (direct user tap).
            guard !isDelegateFromProgrammaticChange else { return }
            if !parent.isFocused {
                parent.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            guard !isDelegateFromProgrammaticChange else { return }
            // Skip when the field is being torn down (view removed from hierarchy).
            // `window == nil` distinguishes teardown-resign from user-initiated resign,
            // so a landscape→portrait rotation doesn't cascade `focusedField = nil`
            // through the delegate and blow away the field the parent view wants to
            // restore focus to.
            guard textField.window != nil else { return }
            if parent.isFocused {
                parent.isFocused = false
            }
        }

        private enum Constants {
            /**
             ~60 × 25 ms = ~1.5 s of retry budget. Enough to cover a landscape /
             sheet-presentation transition where the view is briefly created before
             it's attached to a window.
             */
            static let focusRetryCount = 60
            static let focusRetryIntervalMs = 25
        }
    }
}
