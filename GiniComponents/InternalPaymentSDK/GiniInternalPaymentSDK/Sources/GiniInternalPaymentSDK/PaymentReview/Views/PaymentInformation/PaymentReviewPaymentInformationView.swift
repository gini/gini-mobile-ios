//
//  PaymentReviewPaymentInformationView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniHealthAPILibrary
import GiniUtilites

struct PaymentReviewPaymentInformationView: View {
    
    private enum Field {
        case recipient
        case iban
        case amount
        case paymentPurpose
    }
    
    let onBankSelectionTapped: () -> Void
    let onPayTapped: (PaymentInfo) -> Void
    let onKeyboardDismissed: () -> Void
    
    @ObservedObject private var viewModel: PaymentReviewPaymentInformationObservableModel
    
    @FocusState private var focusedField: Field?
    
    @Binding private var contentHeight: CGFloat
    @Binding private var showBanner: Bool
    
    @Environment(\.isLandscape) private var isLandscape
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

                populateFields()
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
                if let field = newField {
                    viewModel.activeField = mapToActiveField(field)
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
                    if !isLandscape && focusedField == .amount && keyboardHeight > 0 {
                        doneButtonBar
                    }
                    // In landscape the keyboard sits below the inline view; re-inject its
                    // height so the ScrollView scrolls content above it. In portrait the
                    // sheet already repositions above the keyboard — no extra space needed.
                    Color.clear.frame(height: isLandscape ? keyboardHeight : 0)
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

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: Constants.textFieldsContainerSpacing) {
                        ibanTextField
                        amountTextField
                    }
                } else {
                    HStack(spacing: Constants.textFieldsContainerSpacing) {
                        ibanTextField
                        amountTextField
                    }
                }

                paymentPurposeTextField

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: Constants.buttonsContainerSpacing) {
                        paymentProviderSelectionPicker
                        payButton
                    }
                    .padding(.bottom, Constants.buttonsContainerBottomPadding)
                } else {
                    HStack(spacing: Constants.buttonsContainerSpacing) {
                        paymentProviderSelectionPicker
                        payButton
                    }
                    .padding(.bottom, Constants.buttonsContainerBottomPadding)
                }

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
        HStack {
            Text(viewModel.model.strings.infoBarMessage)
                .font(Font(viewModel.model.configuration.infoBar.labelFont))
                .foregroundStyle(Color(viewModel.model.configuration.infoBar.labelTextColor))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.bannerVerticalPadding)
        .background(Color(viewModel.model.configuration.infoBar.backgroundColor))
        .clipShape(
            .rect(
                topLeadingRadius: Constants.bannerCornerRadius,
                bottomLeadingRadius: Constants.zero,
                bottomTrailingRadius: Constants.zero,
                topTrailingRadius: Constants.bannerCornerRadius
            )
        )
        .offset(y: isLandscape ? Constants.zero : Constants.bannerYOffset)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel(viewModel.model.strings.infoBarMessage)
    }
    
    @ViewBuilder
    private var recipientTextField: some View {
        TextField(Constants.emptyString, text: $viewModel.recipientInputState.text)
        .focused($focusedField, equals: .recipient)
        .disabled(viewModel.isFieldsLocked)
        .textFieldStyle(GiniTextFieldStyle(lockedIcon: viewModel.lockIcon,
                                           title: viewModelStrings.fieldPlaceholders.recipient,
                                           state: fieldState(for: .recipient, hasError: viewModel.recipientInputState.hasError),
                                           errorMessage: viewModel.recipientInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration,
                                           onTap: { focusedField = .recipient }))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleRecipientFocusChange(isFocused: newFocus == .recipient)
            }
        }
    }
    
    @ViewBuilder
    private var ibanTextField: some View {
        TextField(Constants.emptyString, text: $viewModel.ibanInputState.text)
        .focused($focusedField, equals: .iban)
        .disabled(viewModel.isFieldsLocked)
        .textInputAutocapitalization(.characters)
        .textFieldStyle(GiniTextFieldStyle(lockedIcon: viewModel.lockIcon,
                                           title: viewModelStrings.fieldPlaceholders.iban,
                                           state: fieldState(for: .iban, hasError: viewModel.ibanInputState.hasError),
                                           errorMessage: viewModel.ibanInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration,
                                           onTap: { focusedField = .iban }))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleIBANFocusChange(isFocused: newFocus == .iban)
            }
        }
    }
    
    @ViewBuilder
    private var amountTextField: some View {
        TextField(Constants.emptyString, text: $viewModel.amountInputState.text)
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
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.fieldPlaceholders.amount,
                                           state: fieldState(for: .amount, hasError: viewModel.amountInputState.hasError),
                                           errorMessage: viewModel.amountInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration,
                                           onTap: { focusedField = .amount }))
    }
    
    @ViewBuilder
    private var paymentPurposeTextField: some View {
        TextField(Constants.emptyString, text: $viewModel.paymentPurposeInputState.text)
        .focused($focusedField, equals: .paymentPurpose)
        .disabled(viewModel.isFieldsLocked)
        .textFieldStyle(GiniTextFieldStyle(lockedIcon: viewModel.lockIcon,
                                           title: viewModelStrings.fieldPlaceholders.usage,
                                           state: fieldState(for: .paymentPurpose, hasError: viewModel.paymentPurposeInputState.hasError),
                                           errorMessage: viewModel.paymentPurposeInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration,
                                           onTap: { focusedField = .paymentPurpose }))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handlePaymentPurposeFocusChange(isFocused: newFocus == .paymentPurpose)
            }
        }
    }
    
    @ViewBuilder
    private var paymentProviderSelectionPicker: some View {
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
                
                if let chevronImage = viewModel.model.configuration.banksPicker.chevronDownIcon,
                   let chevronDownIconColor = viewModel.model.configuration.banksPicker.chevronDownIconColor {
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
        .background(Color(viewModel.model.secondaryButtonConfiguration.backgroundColor))
        .clipShape(.rect(cornerRadius: viewModel.model.secondaryButtonConfiguration.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: viewModel.model.secondaryButtonConfiguration.cornerRadius)
                .stroke(Color(viewModel.model.secondaryButtonConfiguration.borderColor),
                        lineWidth: viewModel.model.secondaryButtonConfiguration.borderWidth)
        )
        .accessibilityLabel(viewModelStrings.bankSelectionAccessibility.selectBankText)
        .accessibilityHint(viewModelStrings.bankSelectionAccessibility.selectBankHint)
    }
    
    @ViewBuilder
    private var payButton: some View {
        if let selectedPaymentProviderBackgroundColor = viewModel.selectedPaymentProvider.colors.background.toColor(),
           let selectedPaymentProviderTextColor = viewModel.selectedPaymentProvider.colors.text.toColor() {
            Button(action: {
                if validateFields() {
                    onPayTapped(buildPaymentInfo())
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
    private var poweredByGiniView: some View {
        HStack {
            Spacer()
            PoweredByGiniSwiftUIView(viewModel: viewModel.poweredByGiniViewModel)
        }
        .padding(.top, Constants.poweredByGiniTopPadding)
    }
    
    // MARK: Private methods

    private func populateFields() {
        viewModel.populateFieldsIfNeeded()
    }
    
    private func buildPaymentInfo() -> PaymentInfo {
        let paymentInfo = viewModel.buildPaymentInfo(recipient: viewModel.recipientInputState.text,
                                                     iban: viewModel.ibanInputState.text,
                                                     amount: viewModel.amountToPay.extractionString,
                                                     purpose: viewModel.paymentPurposeInputState.text)
        
        return paymentInfo
    }
    
    private func adjustAmountValue(updatedText: String) {
        viewModel.amountInputState.hasError = false
        
        if let result = viewModel.adjustAmountValue(text: updatedText) {
            viewModel.amountInputState.text = result.adjustedText
            viewModel.amountToPay.value = result.newValue
        }
    }
    
    private func fieldState(for field: Field, hasError: Bool) -> GiniTextFieldState {
        if hasError {
            return .error
        } else if focusedField == field {
            return .focused
        } else {
            return .normal
        }
    }
    
    private func validateFields() -> Bool {
        let isValid = viewModel.validateAllFields(recipient: viewModel.recipientInputState.text,
                                                  iban: viewModel.ibanInputState.text,
                                                  amount: viewModel.amountInputState.text,
                                                  amountValue: viewModel.amountToPay.value,
                                                  purpose: viewModel.paymentPurposeInputState.text)
        
        viewModel.updateFieldErrorStates()
        
        return isValid
    }
    // MARK: - Orientation Helpers

    /**
     Maps the private `Field` enum to the model-level `ActivePaymentField`
     so the focused field can survive view recreation on orientation change.
     */
    private func mapToActiveField(_ field: Field) -> ActivePaymentField {
        switch field {
            case .recipient: return .recipient
            case .iban: return .iban
            case .amount: return .amount
            case .paymentPurpose: return .paymentPurpose
        }
    }

    /**
     Inverse mapping: `ActivePaymentField` → `Field`.
     */
    private func mapToFocusField(_ activeField: ActivePaymentField) -> Field {
        switch activeField {
            case .recipient: return .recipient
            case .iban: return .iban
            case .amount: return .amount
            case .paymentPurpose: return .paymentPurpose
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
            focusedField = mapToFocusField(field)
        }
    }

    // MARK: - Focus Change Handlers

    private func handleRecipientFocusChange(isFocused: Bool) {
        if isFocused {
            viewModel.recipientInputState.hasError = false
        } else {
            viewModel.recipientInputState.hasError = !viewModel.validateRecipient(viewModel.recipientInputState.text)
            viewModel.recipientInputState.errorMessage = viewModel.recipientError
            
            // Announce error to VoiceOver
            if viewModel.recipientInputState.hasError,
                let errorMessage = viewModel.recipientError {
                UIAccessibility.post(notification: .announcement, argument: errorMessage)
            }
        }
    }

    private func handleIBANFocusChange(isFocused: Bool) {
        if isFocused {
            viewModel.ibanInputState.hasError = false
        } else {
            viewModel.ibanInputState.hasError = !viewModel.validateIBAN(viewModel.ibanInputState.text)
            viewModel.ibanInputState.errorMessage = viewModel.ibanError
            
            // Announce error to VoiceOver
            if viewModel.ibanInputState.hasError,
                let errorMessage = viewModel.ibanError {
                UIAccessibility.post(notification: .announcement, argument: errorMessage)
            }
        }
    }

    private func handleAmountFocusChange(isFocused: Bool) {
        if isFocused {
            viewModel.amountInputState.text = viewModel.amountToPay.stringWithoutSymbol ?? Constants.emptyString
        } else {
            if !viewModel.amountInputState.text.isEmpty,
               let decimalAmount = viewModel.amountInputState.text.decimal() {
                viewModel.amountToPay.value = decimalAmount
                
                if decimalAmount > 0,
                   let amountString = viewModel.amountToPay.string {
                    viewModel.amountInputState.text = amountString
                } else {
                    viewModel.amountInputState.text = Constants.emptyString
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

    private func handlePaymentPurposeFocusChange(isFocused: Bool) {
        if isFocused {
            viewModel.paymentPurposeInputState.hasError = false
        } else {
            viewModel.paymentPurposeInputState.hasError = !viewModel.validatePaymentPurpose(viewModel.paymentPurposeInputState.text)
            viewModel.paymentPurposeInputState.errorMessage = viewModel.paymentPurposeError
            
            // Announce error to VoiceOver
            if viewModel.paymentPurposeInputState.hasError,
                let errorMessage = viewModel.paymentPurposeError {
                UIAccessibility.post(notification: .announcement, argument: errorMessage)
            }
        }
    }
    
    private struct Constants {
        static let emptyString = ""
        static let zero = 0.0
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
