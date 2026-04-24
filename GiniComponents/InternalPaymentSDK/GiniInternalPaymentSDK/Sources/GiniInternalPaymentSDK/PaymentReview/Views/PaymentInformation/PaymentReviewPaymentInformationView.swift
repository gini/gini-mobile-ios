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
            .overlay(alignment: .top) {
                if showBanner {
                    infoBannerView
                        .onAppear {
                            UIAccessibility.post(notification: .announcement,
                                                 argument: viewModel.model.strings.infoBarMessage)
                        }
                }
            }
            .onAppear {
                viewModel.isViewVisible = true

                viewModel.populateFieldsIfNeeded()
                // Notify VoiceOver that a new screen (the sheet) appeared,
                // so it moves focus into the sheet content.
                UIAccessibility.post(notification: .screenChanged, argument: nil)
                // After a rotation the view is recreated; restore keyboard if it was open.
                restoreFocusIfNeeded()
            }
            .onDisappear {
                viewModel.isViewVisible = false
            }
        // Track which field is active so it can be restored after orientation changes.
            .onChange(of: focusedField) { newField in
                handleFocusedFieldChange(newField)
            }
            .background(Color(.systemBackground))
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                keyboardHeight = frame.height
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
    }

    // MARK: Private views

    @ViewBuilder
    private var scrollView: some View {
        baseScrollView
            // Keyboard safe area is suppressed so neither portrait nor landscape creates
            // an automatic gap. Keyboard space is re-injected explicitly via safeAreaInset.
            .ignoresSafeArea(.keyboard)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    // Done button shown here only in portrait (bottom-sheet mode). In landscape
                    // the outer PaymentReviewContentView renders a full-width Done toolbar above
                    // the keyboard, so the narrow per-panel bar is suppressed.
                    if !giniLayout.isLandscape && focusedField == .amount && keyboardHeight > 0 {
                        doneButtonBar
                    }
                    // In landscape the keyboard sits below the inline view; re-inject its
                    // height so the ScrollView scrolls content above it. In portrait the
                    // sheet already repositions above the keyboard — no extra space needed.
                    Color.clear.frame(height: giniLayout.isLandscape ? keyboardHeight : 0)
                }
            }
    }

    @ViewBuilder
    private var doneButtonBar: some View {
        HStack {
            Spacer()
            Button(viewModelStrings.keyboardDoneButtonTitle) {
                onKeyboardDismissed()
                focusedField = nil
            }
            .padding(.horizontal, Constants.doneButtonHorizontalPadding)
        }
        .frame(height: Constants.doneButtonBarHeight)
        .background(Color(UIColor.systemGroupedBackground))
        .overlay(alignment: .top) { Divider() }
    }

    private var baseScrollView: some View {
        ScrollView {
            VStack(spacing: Constants.textFieldsContainerSpacing) {
                recipientTextField

                adaptiveStack(spacing: Constants.textFieldsContainerSpacing) {
                    ibanTextField
                    amountTextField
                }

                paymentPurposeTextField

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
            .getHeight(for: $contentHeight)
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
        .offset(y: giniLayout.isLandscape ? 0.0 : Constants.bannerYOffset)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel(viewModel.model.strings.infoBarMessage)
    }
    
    @ViewBuilder
    private var recipientTextField: some View {
        TextField("", text: $viewModel.recipientInputState.text)
        .focused($focusedField, equals: .recipient)
        .disabled(viewModel.isFieldsLocked)
        .textFieldStyle(makeTextFieldStyle(title: viewModelStrings.fieldPlaceholders.recipient,
                                           field: .recipient,
                                           inputState: viewModel.recipientInputState,
                                           lockedIcon: viewModel.lockIcon))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleFocusChange(isFocused: newFocus == .recipient,
                                  inputState: \.recipientInputState,
                                  validate: viewModel.validateRecipient,
                                  error: \.recipientError)
            }
        }
    }
    
    @ViewBuilder
    private var ibanTextField: some View {
        TextField("", text: $viewModel.ibanInputState.text)
        .focused($focusedField, equals: .iban)
        .disabled(viewModel.isFieldsLocked)
        .textInputAutocapitalization(.characters)
        .textFieldStyle(makeTextFieldStyle(title: viewModelStrings.fieldPlaceholders.iban,
                                           field: .iban,
                                           inputState: viewModel.ibanInputState,
                                           lockedIcon: viewModel.lockIcon))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleFocusChange(isFocused: newFocus == .iban,
                                  inputState: \.ibanInputState,
                                  validate: viewModel.validateIBAN,
                                  error: \.ibanError)
            }
        }
    }
    
    @ViewBuilder
    private var amountTextField: some View {
        TextField("", text: $viewModel.amountInputState.text)
        .focused($focusedField, equals: .amount)
        .onChange(of: viewModel.amountInputState.text) { newValue in
            adjustAmountValue(updatedText: newValue)
        }
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleAmountFocusChange(isFocused: newFocus == .amount)
            }
        }
        .keyboardType(.decimalPad)
        .textFieldStyle(makeTextFieldStyle(title: viewModelStrings.fieldPlaceholders.amount,
                                           field: .amount,
                                           inputState: viewModel.amountInputState))
    }
    
    @ViewBuilder
    private var paymentPurposeTextField: some View {
        TextField("", text: $viewModel.paymentPurposeInputState.text)
        .focused($focusedField, equals: .paymentPurpose)
        .disabled(viewModel.isFieldsLocked)
        .textFieldStyle(makeTextFieldStyle(title: viewModelStrings.fieldPlaceholders.usage,
                                           field: .paymentPurpose,
                                           inputState: viewModel.paymentPurposeInputState,
                                           lockedIcon: viewModel.lockIcon))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleFocusChange(isFocused: newFocus == .paymentPurpose,
                                  inputState: \.paymentPurposeInputState,
                                  validate: viewModel.validatePaymentPurpose,
                                  error: \.paymentPurposeError)
            }
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
            .frame(width: Constants.paymentProviderPickerSize.width,
                   height: Constants.paymentProviderPickerSize.height)
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
                if viewModel.validateAllFields() { viewModel.updateFieldErrorStates(); onPayTapped(viewModel.buildPaymentInfo()) }
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
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: spacing) { content() }
        } else {
            HStack(spacing: spacing) { content() }
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
    
    // MARK: Private methods

    private func adjustAmountValue(updatedText: String) {
        viewModel.amountInputState.hasError = false
        
        if let result = viewModel.adjustAmountValue(text: updatedText) {
            viewModel.amountInputState.text = result.adjustedText
            viewModel.amountToPay.value = result.newValue
        }
    }
    
    private func fieldState(for field: ActivePaymentField, hasError: Bool) -> GiniTextFieldState {
        if hasError {
            return .error
        } else if focusedField == field {
            return .focused
        } else {
            return .normal
        }
    }

    private func makeTextFieldStyle(
        title: String,
        field: ActivePaymentField,
        inputState: GiniInputFieldState,
        lockedIcon: Image? = nil
    ) -> GiniTextFieldStyle {
        GiniTextFieldStyle(lockedIcon: lockedIcon,
                           title: title,
                           state: fieldState(for: field, hasError: inputState.hasError),
                           errorMessage: inputState.errorMessage,
                           normalConfiguration: textFieldConfiguration,
                           focusedConfiguration: focusedTextFieldConfiguration,
                           errorConfiguration: errorTextFieldConfiguration,
                           onTap: { focusedField = field })
    }
    
    // MARK: - Orientation Helpers

    /**
     Handles focus changes on the active field.
     When focus moves to a field, the model's `activeField` and `isAmountFieldFocused` are updated.
     When focus is cleared, amount-focus is cleared immediately and `activeField` is cleared
     after a short delay — distinguishing a user keyboard dismissal from a rotation-triggered view recreation.
     */
    private func handleFocusedFieldChange(_ newField: ActivePaymentField?) {
        if let field = newField {
            viewModel.activeField = field
            viewModel.isAmountFieldFocused = (field == .amount)
        } else {
            // Clear amount-focus immediately so the Done toolbar hides right away.
            viewModel.isAmountFieldFocused = false
            // Don't clear activeField immediately: the same nil event fires during rotation
            // (view is destroyed) AND when the user manually dismisses the keyboard.
            // Capture the current field so the task can verify nothing changed during the delay:
            //   - Still visible + focus still nil + same field → user dismissed → clear activeField
            //   - Gone (rotation) or focus moved to another field → keep activeField for restoration
            let fieldToClear = viewModel.activeField
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 s
                if viewModel.isViewVisible,
                   focusedField == nil,
                   viewModel.activeField == fieldToClear {
                    viewModel.activeField = nil
                }
            }
        }
    }

    /**
     Re-applies keyboard focus after the view is recreated by an orientation change.
     The delay lets the rotation animation and any pending keyboard dismissal finish
     before requesting focus again.
     */
    private func restoreFocusIfNeeded() {
        guard let field = viewModel.activeField else { return }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 s
            focusedField = field
        }
    }

    // MARK: - Focus Change Handlers

    private func handleFocusChange(
        isFocused: Bool,
        inputState: ReferenceWritableKeyPath<PaymentReviewPaymentInformationObservableModel, GiniInputFieldState>,
        validate: (String) -> Bool,
        error: KeyPath<PaymentReviewPaymentInformationObservableModel, String?>
    ) {
        if isFocused {
            viewModel[keyPath: inputState].hasError = false
        } else {
            let text = viewModel[keyPath: inputState].text
            viewModel[keyPath: inputState].hasError = !validate(text)
            viewModel[keyPath: inputState].errorMessage = viewModel[keyPath: error]
            if viewModel[keyPath: inputState].hasError, let msg = viewModel[keyPath: error] {
                UIAccessibility.post(notification: .announcement, argument: msg)
            }
        }
    }

    private func handleAmountFocusChange(isFocused: Bool) {
        if isFocused {
            viewModel.amountInputState.text = viewModel.amountToPay.stringWithoutSymbol ?? ""
        } else {
            if !viewModel.amountInputState.text.isEmpty,
               let decimalAmount = viewModel.amountInputState.text.decimal() {
                viewModel.amountToPay.value = decimalAmount
                
                if decimalAmount > 0,
                   let amountString = viewModel.amountToPay.string {
                    viewModel.amountInputState.text = amountString
                } else {
                    viewModel.amountInputState.text = ""
                }
            }
            
            viewModel.amountInputState.hasError = !viewModel.validateAmount(viewModel.amountInputState.text, amount: viewModel.amountToPay.value)
            viewModel.amountInputState.errorMessage = viewModel.amountError
            
            // Announce error to VoiceOver
            if viewModel.amountInputState.hasError,
                let errorMessage = viewModel.amountError {
                UIAccessibility.post(notification: .announcement, argument: errorMessage)
            }
        }
    }

    private struct Constants {
        static let bannerVerticalPadding = 16.0
        static let bannerCornerRadius = 12.0
        static let bannerYOffset = -8.0
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
