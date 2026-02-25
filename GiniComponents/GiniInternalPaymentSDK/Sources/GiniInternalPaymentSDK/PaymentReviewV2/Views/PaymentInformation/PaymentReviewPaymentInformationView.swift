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
    
    @ObservedObject private var viewModel: PaymentReviewPaymentInformationObservableModel
    
    @State private var amountToPay: Price
    
    @State private var recipientInputState = GiniInputFieldState(text: Constants.emptyString,
                                                                 hasError: false)
    @State private var ibanInputState = GiniInputFieldState(text: Constants.emptyString,
                                                            hasError: false)
    @State private var amountInputState = GiniInputFieldState(text: Constants.emptyString,
                                                              hasError: false)
    @State private var paymentPurposeInputState = GiniInputFieldState(text: Constants.emptyString,
                                                                      hasError: false)
    
    @FocusState private var focusedField: Field?
    
    @Binding private var contentHeight: CGFloat
    @Binding private var collapsedHeight: CGFloat
    @Binding private var showBanner: Bool
    
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
         collapsedHeight: Binding<CGFloat>,
         showBanner: Binding<Bool>,
         onBankSelectionTapped: @escaping () -> Void,
         onPayTapped: @escaping (PaymentInfo) -> Void) {
        let observableModel = viewModel
        self.viewModel = observableModel
        self._contentHeight = contentHeight
        self._collapsedHeight = collapsedHeight
        self._showBanner = showBanner
        self.onBankSelectionTapped = onBankSelectionTapped
        self.onPayTapped = onPayTapped
        self.amountToPay = Price(value: 0, currencyCode: "€")
    }
    
    var body: some View {
        VStack(spacing: Constants.zero) {
            VStack(spacing: Constants.textFieldsContainerSpacing) {
                recipientTextField
                
                HStack(spacing: Constants.textFieldsContainerSpacing) {
                    ibanTextField
                    amountTextField
                }
                
                paymentPurposeTextField
                
                HStack(spacing: Constants.buttonsContainerSpacing) {
                    paymentProviderSelectionPicker
                    payButton
                }
                .getHeight(for: $collapsedHeight)
            }
            .padding(.horizontal, Constants.textFieldsContainerHorizontalPadding)
            .padding(.top, Constants.textFieldsContainerTopPadding)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            if showBanner {
                infoBannerView
            }
        }
        .onAppear {
            populateFields()
        }
        .getHeight(for: $contentHeight)
    }
    
    // MARK: Private views
    
    @ViewBuilder
    private var infoBannerView: some View {
        HStack {
            Text(viewModel.model.strings.infoBarMessage)
                .font(Font(viewModel.model.configuration.infoBarLabelFont))
                .foregroundStyle(Color(viewModel.model.configuration.infoBarLabelTextColor))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.bannerVerticalPadding)
        .background(Color(viewModel.model.configuration.infoBarBackgroundColor))
        .clipShape(
            .rect(
                topLeadingRadius: Constants.bannerCornerRadius,
                bottomLeadingRadius: Constants.zero,
                bottomTrailingRadius: Constants.zero,
                topTrailingRadius: Constants.bannerCornerRadius
            )
        )
        .offset(y: Constants.bannerYOffset)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    @ViewBuilder
    private var recipientTextField: some View {
        TextField(Constants.emptyString, text: $recipientInputState.text)
        .focused($focusedField, equals: .recipient)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.recipientFieldPlaceholder,
                                           state: fieldState(for: .recipient, hasError: recipientInputState.hasError),
                                           errorMessage: recipientInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleRecipientFocusChange(isFocused: newFocus == .recipient)
            }
        }
    }
    
    @ViewBuilder
    private var ibanTextField: some View {
        TextField(Constants.emptyString, text: $ibanInputState.text)
        .focused($focusedField, equals: .iban)
        .textInputAutocapitalization(.characters)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.ibanFieldPlaceholder,
                                           state: fieldState(for: .iban, hasError: ibanInputState.hasError),
                                           errorMessage: ibanInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleIBANFocusChange(isFocused: newFocus == .iban)
            }
        }
    }
    
    @ViewBuilder
    private var amountTextField: some View {
        TextField(Constants.emptyString, text: $amountInputState.text)
        .focused($focusedField, equals: .amount)
        .onChange(of: amountInputState.text) { newValue in
            adjustAmountValue(updatedText: newValue)
        }
        .onChange(of: focusedField) { newFocus in
            Task { @MainActor in
                handleAmountFocusChange(isFocused: newFocus == .amount)
            }
        }
        .keyboardType(.decimalPad)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.amountFieldPlaceholder,
                                           state: fieldState(for: .amount, hasError: amountInputState.hasError),
                                           errorMessage: amountInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
    }
    
    @ViewBuilder
    private var paymentPurposeTextField: some View {
        TextField(Constants.emptyString, text: $paymentPurposeInputState.text)
        .focused($focusedField, equals: .paymentPurpose)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.usageFieldPlaceholder,
                                           state: fieldState(for: .paymentPurpose, hasError: paymentPurposeInputState.hasError),
                                           errorMessage: paymentPurposeInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
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
                        .cornerRadius(Constants.paymentProviderPickerCornerRadius)
                }
                
                if let chevronImage = viewModel.model.configuration.chevronDownIcon,
                   let chevronDownIconColor = viewModel.model.configuration.chevronDownIconColor {
                    Image(uiImage: chevronImage)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.paymentProviderPickerChevronSize.width,
                               height: Constants.paymentProviderPickerChevronSize.height)
                        .tint(Color(chevronDownIconColor))
                }
            }
            .frame(width: Constants.paymentProviderPickerSize.width,
                   height: Constants.paymentProviderPickerSize.height)
            .padding(.vertical, Constants.paymentProviderPickerVerticalPadding)
        }
        .background(Color(viewModel.model.secondaryButtonConfiguration.backgroundColor))
        .cornerRadius(viewModel.model.secondaryButtonConfiguration.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: viewModel.model.secondaryButtonConfiguration.cornerRadius)
                .stroke(Color(viewModel.model.secondaryButtonConfiguration.borderColor),
                        lineWidth: viewModel.model.secondaryButtonConfiguration.borderWidth)
        )
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
            .cornerRadius(viewModel.model.primaryButtonConfiguration.cornerRadius)
            .font(Font(viewModel.model.primaryButtonConfiguration.titleFont))
            .frame(height: Constants.payButtonHeight)
        }
    }
    
    // MARK: Private methods
    
    private func populateFields() {
        let values = viewModel.getInitialFieldValues()
        recipientInputState.text = values.recipient
        ibanInputState.text = values.iban
        paymentPurposeInputState.text = values.purpose
        
        if !values.amount.isEmpty, let price = Price(extractionString: values.amount) {
            amountToPay = price
            amountInputState.text = price.string ?? ""
        }
    }
    
    private func buildPaymentInfo() -> PaymentInfo {
        let paymentInfo = viewModel.buildPaymentInfo(recipient: recipientInputState.text,
                                                     iban: ibanInputState.text,
                                                     amount: amountToPay.extractionString,
                                                     purpose: paymentPurposeInputState.text)
        
        return paymentInfo
    }
    
    private func adjustAmountValue(updatedText: String) {
        amountInputState.hasError = false
        
        if let result = viewModel.adjustAmountValue(text: updatedText) {
            amountInputState.text = result.adjustedText
            amountToPay.value = result.newValue
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
        let isValid = viewModel.validateAllFields(recipient: recipientInputState.text,
                                                  iban: ibanInputState.text,
                                                  amount: amountInputState.text,
                                                  amountValue: amountToPay.value,
                                                  purpose: paymentPurposeInputState.text)
        
        updateFieldStates()
        
        return isValid
    }
    
    private func updateFieldStates() {
        recipientInputState.hasError = viewModel.recipientError != nil
        recipientInputState.errorMessage = viewModel.recipientError
        
        ibanInputState.hasError = viewModel.ibanError != nil
        ibanInputState.errorMessage = viewModel.ibanError
        
        amountInputState.hasError = viewModel.amountError != nil
        amountInputState.errorMessage = viewModel.amountError
        
        paymentPurposeInputState.hasError = viewModel.paymentPurposeError != nil
        paymentPurposeInputState.errorMessage = viewModel.paymentPurposeError
    }
    
    // MARK: - Focus Change Handlers

    private func handleRecipientFocusChange(isFocused: Bool) {
        if isFocused {
            recipientInputState.hasError = false
        } else if !recipientInputState.text.isEmpty {
            recipientInputState.hasError = !viewModel.validateRecipient(recipientInputState.text)
            recipientInputState.errorMessage = viewModel.recipientError
        }
    }

    private func handleIBANFocusChange(isFocused: Bool) {
        if isFocused {
            ibanInputState.hasError = false
        } else if !ibanInputState.text.isEmpty {
            ibanInputState.hasError = !viewModel.validateIBAN(ibanInputState.text)
            ibanInputState.errorMessage = viewModel.ibanError
        }
    }

    private func handleAmountFocusChange(isFocused: Bool) {
        if isFocused {
            amountInputState.text = amountToPay.stringWithoutSymbol ?? Constants.emptyString
        } else {
            if !amountInputState.text.isEmpty,
               let decimalAmount = amountInputState.text.decimal() {
                amountToPay.value = decimalAmount
                
                if decimalAmount > 0,
                   let amountString = amountToPay.string {
                    amountInputState.text = amountString
                } else {
                    amountInputState.text = Constants.emptyString
                }
            }
            
            amountInputState.hasError = !viewModel.validateAmount(amountInputState.text, amount: amountToPay.value)
            amountInputState.errorMessage = viewModel.amountError
        }
    }

    private func handlePaymentPurposeFocusChange(isFocused: Bool) {
        if isFocused {
            paymentPurposeInputState.hasError = false
        } else if !paymentPurposeInputState.text.isEmpty {
            paymentPurposeInputState.hasError = !viewModel.validatePaymentPurpose(paymentPurposeInputState.text)
            paymentPurposeInputState.errorMessage = viewModel.paymentPurposeError
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
        static let textFieldsContainerHorizontalPadding = 16.0
        static let textFieldsContainerTopPadding = 32.0
    }
}
