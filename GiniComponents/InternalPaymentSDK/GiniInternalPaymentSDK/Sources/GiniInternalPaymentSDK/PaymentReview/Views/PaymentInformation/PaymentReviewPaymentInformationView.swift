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
    
    @FocusState private var focusedField: ActivePaymentField?
    
    @Binding private var contentHeight: CGFloat
    @Binding private var showBanner: Bool
    
    @Environment(\.giniLayout) private var giniLayout
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var keyboardHeight: CGFloat = 0
    // Cancels a pending keyboardWillHide zero when a new keyboardWillShow fires (keyboard-type switch).
    @State private var keyboardHideToken = 0

    // Landscape doc-collection layout: side-by-side panels, keyboard scroll is manual.
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
        keyboardToolbarIfNeeded(
            scrollView
                .onAppear {
                    viewModel.isViewVisible = true
                    viewModel.populateFieldsIfNeeded()
                    // Move VoiceOver focus into sheet content on appear.
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                    // Restore focus after rotation recreates the view.
                    restoreFocusIfNeeded()
                }
                .onDisappear {
                    viewModel.isViewVisible = false
                }
                .onChange(of: focusedField) { newField in
                    handleFocusedFieldChange(newField)
                }
                .background(Color(.systemBackground))
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    keyboardHideToken += 1
                    let newHeight = max(keyboardHeight, frame.height)
                    guard newHeight != keyboardHeight else { return }
                    // Animate spacer growth in landscape so a size change between keyboard types
                    // (e.g. decimalPad+toolbar → default+toolbar) slides smoothly rather than jumps.
                    if isDocCollection {
                        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                        withAnimation(.easeInOut(duration: duration)) {
                            keyboardHeight = newHeight
                        }
                    } else {
                        keyboardHeight = newHeight
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    // Defer so a keyboard-type switch (hide → show in the same run-loop) cancels the zero.
                    let token = keyboardHideToken
                    DispatchQueue.main.async {
                        guard keyboardHideToken == token else { return }
                        keyboardHeight = 0
                    }
                }
        )
    }

    // Attaches the iOS 26 Liquid Glass keyboard toolbar without creating an empty UIToolbar
    // on iOS <26 (which would log a harmless but noisy _UIToolbarContentView.width==0 warning).
    @ViewBuilder
    private func keyboardToolbarIfNeeded<V: View>(_ base: V) -> some View {
        if #available(iOS 26, *) {
            base.toolbar {
                if focusedField == .amount && keyboardHeight > 0 {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(viewModelStrings.keyboardDoneButtonTitle) {
                            dismissAmountKeyboard()
                        }
                    }
                }
            }
        } else {
            base
        }
    }

    // MARK: Private views

    @ViewBuilder
    private var scrollView: some View {
        if !isDocCollection {
            // Sheet repositions above the keyboard; suppress double-adjustment.
            baseScrollView
                .ignoresSafeArea(.keyboard)
                .safeAreaInset(edge: .bottom) {
                    if focusedField == .amount && keyboardHeight > 0 {
                        if #available(iOS 26, *) {
                            // Reserve height for the floating Liquid Glass button so content
                            // doesn't slide under it at the sheet/keyboard boundary.
                            Color.clear
                                .frame(height: Constants.doneButtonBarHeight)
                                .allowsHitTesting(false)
                        } else {
                            HStack {
                                Spacer()
                                Button(viewModelStrings.keyboardDoneButtonTitle) {
                                    dismissAmountKeyboard()
                                }
                                .padding(.horizontal, Constants.doneButtonHorizontalPadding)
                            }
                            .frame(height: Constants.doneButtonBarHeight)
                            .background(.regularMaterial)
                            .overlay(alignment: .top) { Divider() }
                        }
                    }
                }
        } else {
            // Landscape docCollection: manual spacer keeps content above the keyboard.
            // Done button: ContentView toolbar (iOS <26) or Liquid Glass toolbar (iOS 26+).
            baseScrollView
                .ignoresSafeArea(.keyboard)
                .safeAreaInset(edge: .bottom) {
                    Color.clear
                        .frame(height: keyboardHeight)
                        .allowsHitTesting(false)
                }
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
                guard giniLayout.isLandscape else { return }
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
    
    @ViewBuilder
    private var recipientTextField: some View {
        TextField("", text: $viewModel.recipientInputState.text)
        .focused($focusedField, equals: .recipient)
        .disabled(viewModel.isFieldsLocked)
        .submitLabel(.done)
        .onSubmit {
            clearFocus()
        }
        .textFieldStyle(makeTextFieldStyle(title: viewModelStrings.fieldPlaceholders.recipient,
                                           field: .recipient,
                                           inputState: viewModel.recipientInputState,
                                           lockedIcon: viewModel.lockIcon))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                viewModel.handleFocusChange(isFocused: newFocus == .recipient,
                                            inputState: \.recipientInputState,
                                            validate: viewModel.validateRecipient,
                                            error: \.recipientError)
            }
        }
        .onChange(of: viewModel.recipientInputState.text) { _ in
            // Clearing error while focused replaces the UITextField and dismisses the keyboard.
            guard focusedField != .recipient else { return }
            viewModel.clearErrorOnTextChange(for: \.recipientInputState)
        }
    }
    
    @ViewBuilder
    private var ibanTextField: some View {
        TextField("", text: $viewModel.ibanInputState.text)
        .focused($focusedField, equals: .iban)
        .disabled(viewModel.isFieldsLocked)
        .textInputAutocapitalization(.characters)
        .submitLabel(.done)
        .onSubmit {
            clearFocus()
        }
        .textFieldStyle(makeTextFieldStyle(title: viewModelStrings.fieldPlaceholders.iban,
                                           field: .iban,
                                           inputState: viewModel.ibanInputState,
                                           lockedIcon: viewModel.lockIcon))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                viewModel.handleFocusChange(isFocused: newFocus == .iban,
                                            inputState: \.ibanInputState,
                                            validate: viewModel.validateIBAN,
                                            error: \.ibanError)
            }
        }
        .onChange(of: viewModel.ibanInputState.text) { _ in
            // Clearing error while focused replaces the UITextField and dismisses the keyboard.
            guard focusedField != .iban else { return }
            viewModel.clearErrorOnTextChange(for: \.ibanInputState)
        }
    }
    
    @ViewBuilder
    private var amountTextField: some View {
        TextField("", text: $viewModel.amountInputState.text)
            .focused($focusedField, equals: .amount)
            .onChange(of: viewModel.amountInputState.text) { newValue in
                viewModel.handleAmountTextChange(updatedText: newValue)
                // Error clearing is handled by handleAmountFocusChange, not text change.
            }
            .onChange(of: focusedField) { newFocus in
                Task { @MainActor in
                    viewModel.handleAmountFocusChange(isFocused: newFocus == .amount)
                }
            }
            .keyboardType(.decimalPad)
            .textFieldStyle(makeTextFieldStyle(
                title: viewModelStrings.fieldPlaceholders.amount,
                field: .amount,
                inputState: viewModel.amountInputState
            ))
    }
    
    @ViewBuilder
    private var paymentPurposeTextField: some View {
        TextField("", text: $viewModel.paymentPurposeInputState.text)
        .focused($focusedField, equals: .paymentPurpose)
        .disabled(viewModel.isFieldsLocked)
        .submitLabel(.done)
        .onSubmit {
            clearFocus()
        }
        .textFieldStyle(makeTextFieldStyle(title: viewModelStrings.fieldPlaceholders.usage,
                                           field: .paymentPurpose,
                                           inputState: viewModel.paymentPurposeInputState,
                                           lockedIcon: viewModel.lockIcon))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                viewModel.handleFocusChange(isFocused: newFocus == .paymentPurpose,
                                            inputState: \.paymentPurposeInputState,
                                            validate: viewModel.validatePaymentPurpose,
                                            error: \.paymentPurposeError)
            }
        }
        .onChange(of: viewModel.paymentPurposeInputState.text) { _ in
            // Clearing error while focused replaces the UITextField and dismisses the keyboard.
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

    private func dismissAmountKeyboard() {
        onKeyboardDismissed()
        viewModel.handleAmountFocusChange(isFocused: false)
        focusedField = nil
    }

    // MARK: Private methods

    private func clearFocus() {
        focusedField = nil
        viewModel.activeField = nil
    }

    private func makeTextFieldStyle(title: String,
                                    field: ActivePaymentField,
                                    inputState: GiniInputFieldState,
                                    lockedIcon: Image? = nil) -> GiniTextFieldStyle {
        GiniTextFieldStyle(lockedIcon: lockedIcon,
                           title: title,
                           state: viewModel.fieldState(for: field, hasError: inputState.hasError),
                           errorMessage: inputState.errorMessage,
                           normalConfiguration: textFieldConfiguration,
                           focusedConfiguration: focusedTextFieldConfiguration,
                           errorConfiguration: errorTextFieldConfiguration,
                           onTap: { focusedField = field })
    }
    
    // MARK: - Orientation Helpers

    private func handleFocusedFieldChange(_ newField: ActivePaymentField?) {
        if let field = newField {
            viewModel.activeField = field
            viewModel.isAmountFieldFocused = (field == .amount)
        } else {
            // Hide Done toolbar immediately; delay clearing activeField to distinguish dismiss from rotation.
            viewModel.isAmountFieldFocused = false
            let fieldToClear = viewModel.activeField
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                if viewModel.isViewVisible,
                   focusedField == nil,
                   viewModel.activeField == fieldToClear {
                    viewModel.activeField = nil
                }
            }
        }
    }

    // Delays 400 ms for rotation animation before re-applying focus.
    private func restoreFocusIfNeeded() {
        guard let field = viewModel.activeField else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
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
        static let doneButtonBarHeight = 44.0
        static let doneButtonHorizontalPadding = 16.0
    }
}
