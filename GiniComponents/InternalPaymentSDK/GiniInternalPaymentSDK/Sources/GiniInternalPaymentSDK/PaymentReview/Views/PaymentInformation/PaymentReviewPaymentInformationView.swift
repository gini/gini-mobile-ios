//
//  PaymentReviewPaymentInformationView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniHealthAPILibrary
import GiniUtilites

struct PaymentReviewPaymentInformationView: View {
    
    let onBankSelectionTapped: () -> Void
    let onPayTapped: (PaymentInfo) -> Void
    let onKeyboardDismissed: () -> Void
    
    @ObservedObject private var viewModel: PaymentReviewPaymentInformationObservableModel

    /**
     Every field is a UIKit-backed `GiniPaymentTextField`, so focus is a plain `@State`
     value rather than `@FocusState`. Each field derives its own `isFocused: Binding<Bool>`
     from this via `focusBinding(_:)`.
     */
    @State private var focusedField: ActivePaymentField?

    @Binding private var contentHeight: CGFloat
    @Binding private var showBanner: Bool

    @Environment(\.giniLayout) private var giniLayout
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var keyboardHeight: CGFloat = 0
    /**
     Cancels a pending `keyboardWillHide` zero when a new `keyboardWillShow` fires (keyboard-type switch).
     */
    @State private var keyboardHideToken = 0

    /**
     Instance-local visibility flag. Distinct from `viewModel.isViewVisible` (shared on the
     ObservableObject) — on rotation the NEW view's `onAppear` can fire before the OLD
     view's `onDisappear`, and using this local `@State` keeps the restore Task guard
     reliable per instance.
     */
    @State private var isViewOnScreen: Bool = false

    /**
     One shared `inputAccessoryView` instance across all four fields. iOS keeps it in
     place as first responder moves between fields, so switching fields doesn't reflow
     the keyboard or bounce the sheet detent.
     */
    @State private var sharedAccessoryView = GiniAmountInputAccessoryView()

    /**
     Landscape doc-collection layout: side-by-side panels, keyboard scroll is manual.
     */
    private var isDocCollection: Bool {
        giniLayout.isLandscape && viewModel.model.displayMode != .bottomSheet
    }
    
    private var textFieldConfiguration: TextFieldConfiguration {
        viewModel.model.defaultStyleInputFieldConfiguration
    }
    
    private var focusedTextFieldConfiguration: TextFieldConfiguration {
        viewModel.model.selectionStyleInputFieldConfiguration
    }
    
    private var errorTextFieldConfiguration: TextFieldConfiguration {
        viewModel.model.errorStyleInputFieldConfiguration
    }
    
    private var viewModelStrings: PaymentReviewContainerStrings {
        viewModel.model.strings
    }
    
    init(viewModel: PaymentReviewPaymentInformationObservableModel,
         contentHeight: Binding<CGFloat>,
         showBanner: Binding<Bool>,
         onBankSelectionTapped: @escaping () -> Void,
         onPayTapped: @escaping (PaymentInfo) -> Void,
         onKeyboardDismissed: @escaping () -> Void) {
        self.viewModel = viewModel
        self._contentHeight = contentHeight
        self._showBanner = showBanner
        self.onBankSelectionTapped = onBankSelectionTapped
        self.onPayTapped = onPayTapped
        self.onKeyboardDismissed = onKeyboardDismissed
    }
    
    var body: some View {
        scrollView
            .onAppear {
                isViewOnScreen = true
                viewModel.isViewVisible = true
                viewModel.populateFieldsIfNeeded()
                // Move VoiceOver focus into sheet content on appear.
                UIAccessibility.post(notification: .screenChanged, argument: nil)
                // Restore focus after rotation recreates the view.
                restoreFocusIfNeeded()
            }
            .onDisappear {
                isViewOnScreen = false
                viewModel.isViewVisible = false
            }
            .onChange(of: focusedField) { oldField, newField in
                handleFocusedFieldChange(from: oldField, to: newField)
            }
            .background(Color(.systemBackground))
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                handleKeyboardWillShow(notification)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                handleKeyboardWillHide()
            }
    }

    // MARK: Private keyboard handlers

    private func handleKeyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        // Defer @State writes off the current runloop turn. `keyboardWillShow` is posted
        // synchronously by UIKit inside `becomeFirstResponder`; once the payment review
        // fields are UIKit-backed (later commit) and `updateUIView` calls `becomeFirstResponder`
        // synchronously, writing @State here on the same runloop would happen during
        // SwiftUI's own update pass — producing AttributeGraph cycles and "Modifying state
        // during view update" warnings. Deferring keeps the state write outside the pass.
        Task { @MainActor in
            keyboardHideToken += 1
            // Never shrink during an active keyboard session — avoids a layout jump when
            // switching between keyboard types (e.g. decimalPad+toolbar → default+toolbar
            // → decimalPad+toolbar).
            let newHeight = max(keyboardHeight, frame.height)
            guard newHeight != keyboardHeight else { return }
            // Animate spacer growth in landscape so a size change between keyboard types
            // slides smoothly rather than jumps.
            if isDocCollection {
                withAnimation(.easeInOut(duration: duration)) {
                    keyboardHeight = newHeight
                }
            } else {
                keyboardHeight = newHeight
            }
        }
    }

    private func handleKeyboardWillHide() {
        // Defer so a keyboard-type switch (hide → show in the same run-loop) cancels the zero.
        let token = keyboardHideToken
        Task { @MainActor in
            guard keyboardHideToken == token else { return }
            keyboardHeight = 0
        }
    }

    // MARK: Private views

    @ViewBuilder
    private var scrollView: some View {
        if !isDocCollection {
            sheetScrollView
        } else {
            docCollectionScrollView
        }
    }

    // Sheet context: sheet repositions above the keyboard automatically. The Done
    // affordance is a UIKit `inputAccessoryView` on each field (via `GiniPaymentTextField`),
    // so no in-content bar is inserted here.
    @ViewBuilder
    private var sheetScrollView: some View {
        baseScrollView
            .ignoresSafeArea(.keyboard)
    }

    // Landscape docCollection: manual spacer keeps content above the keyboard.
    // Every field's toolbar is provided by its UIKit `inputAccessoryView`.
    @ViewBuilder
    private var docCollectionScrollView: some View {
        baseScrollView
            .ignoresSafeArea(.keyboard)
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: keyboardHeight)
                    .allowsHitTesting(false)
            }
    }

    private var baseScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    if showBanner {
                        infoBannerView
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .onAppear {
                                UIAccessibility.post(notification: .announcement,
                                                     argument: viewModel.model.strings.infoBarMessage)
                            }
                    }

                    VStack(spacing: Constants.textFieldsContainerSpacing) {
                        recipientTextField
                            .id(ActivePaymentField.recipient)

                        adaptiveStack(spacing: Constants.textFieldsContainerSpacing) {
                            ibanTextField
                                .id(ActivePaymentField.iban)
                            amountTextField
                                .id(ActivePaymentField.amount)
                        }

                        paymentPurposeTextField
                            .id(ActivePaymentField.paymentPurpose)

                        adaptiveStack(spacing: Constants.buttonsContainerSpacing) {
                            paymentProviderSelectionPicker
                            payButton
                        }
                        .padding(.bottom, Constants.buttonsContainerBottomPadding)

                        if viewModel.shouldShowBrandedView {
                            poweredByGiniView
                        }
                    }
                    .padding(.horizontal, Constants.textFieldsContainerHorizontalPadding)
                    .padding(.top, Constants.textFieldsContainerTopPadding)
                }
                .getHeight(for: $contentHeight)
            }
            // Landscape: UIKit-backed fields don't auto-scroll; drive it from keyboardHeight changes.
            // No anchor → minimum scroll: if the field is already visible nothing happens,
            // which avoids a spurious micro-scroll when switching between adjacent fields (IBAN/amount).
            .onChange(of: keyboardHeight) { height in
                guard isDocCollection else { return }
                if height > 0, let field = focusedField {
                    proxy.scrollTo(field)
                } else if height == 0 {
                    proxy.scrollTo(ActivePaymentField.recipient, anchor: .top)
                }
            }
        }
    }

    // MARK: Private views

    @ViewBuilder
    private var infoBannerView: some View {
        let infoBar = viewModel.model.configuration.infoBar
        HStack {
            Text(viewModel.model.strings.infoBarMessage)
                .font(Font(infoBar.labelFont))
                .foregroundStyle(Color(infoBar.labelTextColor))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.bannerVerticalPadding)
        .background(Color(infoBar.backgroundColor))
        .clipShape(
            .rect(
                topLeadingRadius: Constants.bannerCornerRadius,
                bottomLeadingRadius: 0.0,
                bottomTrailingRadius: 0.0,
                topTrailingRadius: Constants.bannerCornerRadius
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel(viewModel.model.strings.infoBarMessage)
    }
    
    // MARK: - Field navigation
    //
    // Field order in the form: recipient → iban → amount → paymentPurpose.
    // Each field's accessory prev/next callbacks jump to the neighbour, matching the Bank
    // SDK's `[nameLabelView, priceLabelView]` navigation pattern. Arrows are disabled at
    // boundaries or when the host has locked the sibling fields.

    @ViewBuilder
    private var recipientTextField: some View {
        GiniPaymentTextField(text: $viewModel.recipientInputState.text,
                             isFocused: focusBinding(.recipient),
                             title: viewModelStrings.fieldPlaceholders.recipient,
                             state: viewModel.fieldState(for: .recipient,
                                                         hasError: viewModel.recipientInputState.hasError),
                             errorMessage: viewModel.recipientInputState.errorMessage,
                             normalConfiguration: textFieldConfiguration,
                             focusedConfiguration: focusedTextFieldConfiguration,
                             errorConfiguration: errorTextFieldConfiguration,
                             keyboardType: .default,
                             autocapitalizationType: .sentences,
                             returnKeyType: .default,
                             isDisabled: viewModel.isFieldsLocked,
                             lockedIcon: viewModel.lockIcon,
                             accessoryView: sharedAccessoryView,
                             accessoryTintColor: accessoryTintColor,
                             isPreviousEnabled: false,
                             isNextEnabled: !viewModel.isFieldsLocked,
                             onPrevious: {},
                             onNext: { focusedField = .iban },
                             onDone: { clearFocus() },
                             onSubmit: { clearFocus() })
            .onChange(of: viewModel.recipientInputState.text) { _ in
                guard focusedField != .recipient else { return }
                viewModel.clearErrorOnTextChange(for: \.recipientInputState)
            }
    }

    @ViewBuilder
    private var ibanTextField: some View {
        GiniPaymentTextField(text: $viewModel.ibanInputState.text,
                             isFocused: focusBinding(.iban),
                             title: viewModelStrings.fieldPlaceholders.iban,
                             state: viewModel.fieldState(for: .iban,
                                                         hasError: viewModel.ibanInputState.hasError),
                             errorMessage: viewModel.ibanInputState.errorMessage,
                             normalConfiguration: textFieldConfiguration,
                             focusedConfiguration: focusedTextFieldConfiguration,
                             errorConfiguration: errorTextFieldConfiguration,
                             keyboardType: .default,
                             autocapitalizationType: .allCharacters,
                             returnKeyType: .default,
                             isDisabled: viewModel.isFieldsLocked,
                             lockedIcon: viewModel.lockIcon,
                             accessoryView: sharedAccessoryView,
                             accessoryTintColor: accessoryTintColor,
                             isPreviousEnabled: !viewModel.isFieldsLocked,
                             isNextEnabled: true,
                             onPrevious: { focusedField = .recipient },
                             onNext: { focusedField = .amount },
                             onDone: { clearFocus() },
                             onSubmit: { clearFocus() })
            .onChange(of: viewModel.ibanInputState.text) { _ in
                guard focusedField != .iban else { return }
                viewModel.clearErrorOnTextChange(for: \.ibanInputState)
            }
    }

    @ViewBuilder
    private var amountTextField: some View {
        GiniPaymentTextField(text: $viewModel.amountInputState.text,
                             isFocused: focusBinding(.amount),
                             title: viewModelStrings.fieldPlaceholders.amount,
                             state: viewModel.fieldState(for: .amount,
                                                         hasError: viewModel.amountInputState.hasError),
                             errorMessage: viewModel.amountInputState.errorMessage,
                             normalConfiguration: textFieldConfiguration,
                             focusedConfiguration: focusedTextFieldConfiguration,
                             errorConfiguration: errorTextFieldConfiguration,
                             keyboardType: .decimalPad,
                             autocapitalizationType: .none,
                             returnKeyType: .default,
                             isDisabled: false,
                             lockedIcon: nil,
                             accessoryView: sharedAccessoryView,
                             accessoryTintColor: accessoryTintColor,
                             isPreviousEnabled: !viewModel.isFieldsLocked,
                             isNextEnabled: !viewModel.isFieldsLocked,
                             onPrevious: { focusedField = .iban },
                             onNext: { focusedField = .paymentPurpose },
                             onDone: dismissAmountKeyboard,
                             onSubmit: {})
            .onChange(of: viewModel.amountInputState.text) { newValue in
                viewModel.handleAmountTextChange(updatedText: newValue)
                // Error clearing is handled by handleAmountFocusChange, not text change.
            }
    }

    @ViewBuilder
    private var paymentPurposeTextField: some View {
        GiniPaymentTextField(text: $viewModel.paymentPurposeInputState.text,
                             isFocused: focusBinding(.paymentPurpose),
                             title: viewModelStrings.fieldPlaceholders.usage,
                             state: viewModel.fieldState(for: .paymentPurpose,
                                                         hasError: viewModel.paymentPurposeInputState.hasError),
                             errorMessage: viewModel.paymentPurposeInputState.errorMessage,
                             normalConfiguration: textFieldConfiguration,
                             focusedConfiguration: focusedTextFieldConfiguration,
                             errorConfiguration: errorTextFieldConfiguration,
                             keyboardType: .default,
                             autocapitalizationType: .sentences,
                             returnKeyType: .default,
                             isDisabled: viewModel.isFieldsLocked,
                             lockedIcon: viewModel.lockIcon,
                             accessoryView: sharedAccessoryView,
                             accessoryTintColor: accessoryTintColor,
                             isPreviousEnabled: true,
                             isNextEnabled: false,
                             onPrevious: { focusedField = .amount },
                             onNext: {},
                             onDone: { clearFocus() },
                             onSubmit: { clearFocus() })
            .onChange(of: viewModel.paymentPurposeInputState.text) { _ in
                guard focusedField != .paymentPurpose else { return }
                viewModel.clearErrorOnTextChange(for: \.paymentPurposeInputState)
            }
    }
    
    @ViewBuilder
    private var paymentProviderSelectionPicker: some View {
        let banksPicker = viewModel.model.configuration.banksPicker
        let secondaryButton = viewModel.model.secondaryButtonConfiguration
        Button(action: {
            onBankSelectionTapped()
        }) {
            HStack(spacing: Constants.paymentProviderPickerSpacing) {
                if let uiImage = UIImage(data: viewModel.selectedPaymentProvider.iconData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.paymentProviderPickerIconSize.width,
                               height: Constants.paymentProviderPickerSize.height)
                        .clipShape(.rect(cornerRadius: Constants.paymentProviderPickerCornerRadius))
                        .accessibilityHidden(true)
                }
                
                if let chevronImage = banksPicker.chevronDownIcon,
                   let chevronDownIconColor = banksPicker.chevronDownIconColor {
                    Image(uiImage: chevronImage)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.paymentProviderPickerChevronSize.width,
                               height: Constants.paymentProviderPickerChevronSize.height)
                        .tint(Color(chevronDownIconColor))
                        .accessibilityHidden(true)
                }
            }
            // At xxxLarge+ the picker is in a VStack; expand to full width so it aligns with payButton.
            .frame(minWidth: dynamicTypeSize >= .xxxLarge ? 0 : Constants.paymentProviderPickerSize.width,
                   maxWidth: dynamicTypeSize >= .xxxLarge ? .infinity : Constants.paymentProviderPickerSize.width,
                   minHeight: Constants.paymentProviderPickerSize.height)
            .padding(.vertical, Constants.paymentProviderPickerVerticalPadding)
        }
        .background(Color(secondaryButton.backgroundColor))
        .clipShape(.rect(cornerRadius: secondaryButton.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: secondaryButton.cornerRadius)
                .stroke(Color(secondaryButton.borderColor),
                        lineWidth: secondaryButton.borderWidth)
        )
        .accessibilityLabel(viewModelStrings.bankSelectionAccessibility.selectBankText)
        .accessibilityHint(viewModelStrings.bankSelectionAccessibility.selectBankHint)
    }
    
    @ViewBuilder
    private var payButton: some View {
        if let selectedPaymentProviderBackgroundColor = viewModel.selectedPaymentProvider.colors.background.toColor(),
           let selectedPaymentProviderTextColor = viewModel.selectedPaymentProvider.colors.text.toColor() {
            Button(action: {
                let isValid = viewModel.validateAllFields()
                viewModel.updateFieldErrorStates()
                if isValid {
                    onPayTapped(viewModel.buildPaymentInfo())
                } else {
                    let firstError = [viewModel.recipientError,
                                      viewModel.ibanError,
                                      viewModel.amountError,
                                      viewModel.paymentPurposeError]
                        .compactMap { $0 }.first
                    if let firstError {
                        // Delay so VoiceOver finishes announcing button activation before error.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UIAccessibility.post(notification: .announcement, argument: firstError)
                        }
                    }
                }
            }) {
                Text(viewModel.model.strings.payInvoiceLabelText)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .foregroundStyle(Color(selectedPaymentProviderTextColor))
            .background(Color(selectedPaymentProviderBackgroundColor))
            .clipShape(.rect(cornerRadius: viewModel.model.primaryButtonConfiguration.cornerRadius))
            .font(Font(viewModel.model.primaryButtonConfiguration.titleFont))
            .frame(minHeight: Constants.payButtonHeight)
            .accessibilityLabel(viewModel.model.strings.payInvoiceLabelText)
            .accessibilityHint(viewModelStrings.bankSelectionAccessibility.payInvoiceHint)
        }
    }
    
    @ViewBuilder
    private func adaptiveStack<Content: View>(spacing: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        // xxxLarge+ uses VStack so wide content gets full width.
        if dynamicTypeSize >= .xxxLarge {
            VStack(spacing: spacing) { content() }
        } else {
            HStack(alignment: .top, spacing: spacing) { content() }
        }
    }

    @ViewBuilder
    private var poweredByGiniView: some View {
        HStack {
            Spacer()
            PoweredByGiniSwiftUIView(viewModel: viewModel.poweredByGiniViewModel)
        }
        .padding(.top, Constants.poweredByGiniTopPadding)
    }

    /**
     Called when the user taps the amount field's Done accessory button. Runs the
     tracking / activeField-clear path via `onKeyboardDismissed`, then clears focus —
     the field's Representable resigns the `UITextField` and validation fires via
     `handleFocusedFieldChange`.
     */
    private func dismissAmountKeyboard() {
        onKeyboardDismissed()
        focusedField = nil
    }

    // MARK: Private methods

    private func clearFocus() {
        focusedField = nil
        viewModel.activeField = nil
    }

    /**
     Two-way `Binding<Bool>` connecting a specific field to the shared `focusedField`
     state. Writing `true` moves focus to this field; writing `false` clears it only if
     this field was the currently focused one (siblings can't clobber a transfer).
     */
    private func focusBinding(_ field: ActivePaymentField) -> Binding<Bool> {
        Binding(
            get: { focusedField == field },
            set: { newValue in
                if newValue {
                    if focusedField != field {
                        focusedField = field
                    }
                } else if focusedField == field {
                    focusedField = nil
                }
            }
        )
    }

    /**
     Shared accessory-toolbar tint. Sourced from the container configuration so host apps
     can override; system blue by default (the `.done` `UIBarButtonItem` uses this tint,
     giving the correct Liquid Glass tick on iOS 26).
     */
    private var accessoryTintColor: UIColor {
        viewModel.model.configuration.keyboardDoneButtonTintColor
    }

    // MARK: - Focus coordination

    /**
     Central handler for focus changes. Runs per-field validation for the field losing
     focus and the field gaining it, and keeps the model in sync.

     Takes the previous focused field explicitly (from SwiftUI's two-parameter
     `onChange`) rather than reading it from `viewModel.activeField`. Callers like
     `clearFocus()` and `trackKeyboardDismissed()` clear `activeField` before this
     runs, so relying on that would leave the switch below with `previousField == nil`
     and skip on-blur validation — which is what caused the "Done on empty field
     doesn't highlight the error" regression.
     */
    private func handleFocusedFieldChange(from previousField: ActivePaymentField?,
                                          to newField: ActivePaymentField?) {
        // Fire on-blur validation for the field losing focus.
        switch previousField {
        case .recipient:
            Task { @MainActor in
                viewModel.handleFocusChange(isFocused: false,
                                            inputState: \.recipientInputState,
                                            validate: viewModel.validateRecipient,
                                            error: \.recipientError)
            }
        case .iban:
            Task { @MainActor in
                viewModel.handleFocusChange(isFocused: false,
                                            inputState: \.ibanInputState,
                                            validate: viewModel.validateIBAN,
                                            error: \.ibanError)
            }
        case .amount:
            if newField != .amount {
                Task { @MainActor in
                    viewModel.handleAmountFocusChange(isFocused: false)
                }
            }
        case .paymentPurpose:
            Task { @MainActor in
                viewModel.handleFocusChange(isFocused: false,
                                            inputState: \.paymentPurposeInputState,
                                            validate: viewModel.validatePaymentPurpose,
                                            error: \.paymentPurposeError)
            }
        case .none:
            break
        }

        if let field = newField {
            viewModel.activeField = field
            viewModel.isAmountFieldFocused = (field == .amount)
            if field == .amount, previousField != .amount {
                Task { @MainActor in
                    viewModel.handleAmountFocusChange(isFocused: true)
                }
            }
        } else {
            viewModel.isAmountFieldFocused = false
            // Deferred `activeField` clear so a view teardown has time to flip
            // `isViewOnScreen` to `false` before we decide to clear:
            //   - Rotation portrait→landscape: `viewWillTransition` dismisses the sheet
            //     with `animated: false`, so `onDismiss` and the payment info view's
            //     `onDisappear` fire within a few ms — well before 100 ms. The guard
            //     then reads `isViewOnScreen == false` and skips → `activeField`
            //     preserved for the landscape restore.
            //   - Grabber drag / tap-outside / Done: view stays on screen, guard
            //     passes at 100 ms → `activeField` cleared → focused-border drops.
            // Also re-checks `focusedField == nil` so a fast re-focus (e.g. user
            // dismisses then taps a field within 100 ms) doesn't get clobbered.
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                guard isViewOnScreen, focusedField == nil else { return }
                viewModel.activeField = nil
            }
        }
    }

    /**
     Waits 500 ms past the rotation / layout transition, then writes `focusedField`.
     Deferring puts the UITextField's `becomeFirstResponder` (triggered by the write)
     safely after all rotation-related state churn — otherwise the sync
     `becomeFirstResponder` inside the Representable's `updateUIView` would run during
     SwiftUI's transition, triggering AttributeGraph cycles and preventing the keyboard
     from actually presenting.
     */
    private func restoreFocusIfNeeded() {
        guard let field = viewModel.activeField else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard isViewOnScreen else { return }
            guard viewModel.activeField == field else { return }
            focusedField = field
        }
    }

    private struct Constants {
        static let bannerVerticalPadding = 16.0
        static let bannerCornerRadius = 12.0
        static let textFieldsContainerSpacing = 8.0
        static let buttonsContainerSpacing = 8.0
        static let paymentProviderPickerSpacing = 12.0
        static let paymentProviderPickerCornerRadius = 6.0
        static let paymentProviderPickerVerticalPadding = 10.0
        static let paymentProviderPickerIconSize = CGSize(width: 36.0, height: 36.0)
        static let paymentProviderPickerChevronSize = CGSize(width: 24.0, height: 24.0)
        static let paymentProviderPickerSize = CGSize(width: 96.0, height: 36.0)
        static let payButtonHeight = 56.0
        static let buttonsContainerBottomPadding = 16.0
        static let textFieldsContainerHorizontalPadding = 16.0
        static let textFieldsContainerTopPadding = 24.0
        static let poweredByGiniTopPadding = 8.0
    }
}
