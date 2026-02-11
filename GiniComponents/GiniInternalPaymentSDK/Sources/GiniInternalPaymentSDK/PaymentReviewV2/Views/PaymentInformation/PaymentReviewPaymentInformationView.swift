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
    @State private var showBanner: Bool
    
    @State private var recipientInputState = GiniInputFieldState(text: Constants.emptyString,
                                                                 hasError: false)
    @State private var ibanInputState = GiniInputFieldState(text: Constants.emptyString,
                                                            hasError: false)
    @State private var amountInputState = GiniInputFieldState(text: Constants.emptyString,
                                                              hasError: false)
    @State private var paymentPurposeInputState = GiniInputFieldState(text: Constants.emptyString,
                                                                      hasError: false)
    
    @FocusState private var focusedField: Field?
    
    @Binding var contentHeight: CGFloat
    @Binding var collapsedHeight: CGFloat
    
    private let ibanValidator = IBANValidator()
    
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
         onBankSelectionTapped: @escaping () -> Void,
         onPayTapped: @escaping (PaymentInfo) -> Void) {
        let observableModel = viewModel
        self.viewModel = observableModel
        self._contentHeight = contentHeight
        self._collapsedHeight = collapsedHeight
        self.onBankSelectionTapped = onBankSelectionTapped
        self.onPayTapped = onPayTapped
        self.amountToPay = Price(value: 0, currencyCode: "€")
        self.showBanner = !viewModel.model.configuration.isInfoBarHidden
    }
    
    var body: some View {
        VStack(spacing: Constants.stackSpacingZero) {
            if showBanner {
                infoBannerView
            }
            
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
        .onAppear {
            Task {
                try await Task.sleep(for: .seconds(viewModel.model.configuration.popupAnimationDuration))
                withAnimation(.easeInOut(duration: 0.3)) {
                    showBanner = false
                }
            }
            
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
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    @ViewBuilder
    private var recipientTextField: some View {
        TextField(Constants.emptyString, text: $recipientInputState.text, onEditingChanged: { isBegin in
            recipientInputState.hasError = isBegin ? false : !isRecipientValid()
        })
        .focused($focusedField, equals: .recipient)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.recipientFieldPlaceholder,
                                           state: fieldState(for: .recipient, hasError: recipientInputState.hasError),
                                           errorMessage: recipientInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
    }
    
    @ViewBuilder
    private var ibanTextField: some View {
        TextField(Constants.emptyString, text: $ibanInputState.text, onEditingChanged: { isBegin in
            ibanInputState.hasError = isBegin ? false : !isIBANValid()
        })
        .focused($focusedField, equals: .iban)
        .textInputAutocapitalization(.characters)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.ibanFieldPlaceholder,
                                           state: fieldState(for: .iban, hasError: ibanInputState.hasError),
                                           errorMessage: ibanInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
    }
    
    @ViewBuilder
    private var amountTextField: some View {
        TextField(Constants.emptyString, text: $amountInputState.text,
                  onEditingChanged: { isBegin in
            if isBegin {
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
                
                amountInputState.hasError = !isAmountValid()
            }
        })
        .focused($focusedField, equals: .amount)
        .onChange(of: amountInputState.text) { newValue in
            adjustAmountValue(updatedText: newValue)
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
        TextField(Constants.emptyString, text: $paymentPurposeInputState.text, onEditingChanged: { isBegin in
            paymentPurposeInputState.hasError = isBegin ? false : !isPaymentPurposeValid()
        })
        .focused($focusedField, equals: .paymentPurpose)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.usageFieldPlaceholder,
                                           state: fieldState(for: .paymentPurpose, hasError: paymentPurposeInputState.hasError),
                                           errorMessage: paymentPurposeInputState.errorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
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
        if !viewModel.extractions.isEmpty {
            populateFieldsWithExtractions(viewModel.extractions)
        } else if let paymentInfo = viewModel.model.paymentInfo {
            populateFieldsWithPaymentInfo(paymentInfo)
        }
    }
    
    private func populateFieldsWithExtractions(_ extractions: [Extraction]) {
        recipientInputState.text = extractions.first(where: { $0.name == "payment_recipient" })?.value ?? Constants.emptyString
        ibanInputState.text = extractions.first(where: { $0.name == "iban" })?.value.uppercased() ?? Constants.emptyString
        paymentPurposeInputState.text = extractions.first(where: { $0.name == "payment_purpose" })?.value ?? Constants.emptyString
        
        if let amountString = viewModel.extractions.first(where: { $0.name == "amount_to_pay" })?.value,
           let amountToPay = Price(extractionString: amountString),
           let amountToPayString = amountToPay.string {
            self.amountToPay = amountToPay
            amountInputState.text = amountToPayString
        }
    }
    
    private func populateFieldsWithPaymentInfo(_ paymentInfo: PaymentInfo) {
        recipientInputState.text = paymentInfo.recipient
        ibanInputState.text = paymentInfo.iban.uppercased()
        paymentPurposeInputState.text = paymentInfo.purpose
        
        if let amountToPay = Price(extractionString: paymentInfo.amount),
           let amountToPayText = amountToPay.string {
            self.amountToPay = amountToPay
            amountInputState.text = amountToPayText
        }
    }
    
    private func buildPaymentInfo() -> PaymentInfo {
        let paymentInfo = PaymentInfo(recipient: recipientInputState.text,
                                      iban: ibanInputState.text,
                                      bic: Constants.emptyString,
                                      amount: amountToPay.extractionString,
                                      purpose: paymentPurposeInputState.text,
                                      paymentUniversalLink: viewModel.selectedPaymentProvider.universalLinkIOS,
                                      paymentProviderId: viewModel.selectedPaymentProvider.id)
        return paymentInfo
    }
    
    private func adjustAmountValue(updatedText: String) {
        amountInputState.hasError = false
        
        if let newPrice = updatedText.toPrice(maxDigitsLength: 7),
           let newAmount = newPrice.stringWithoutSymbol {
            amountInputState.text = newAmount
            amountToPay.value = newPrice.value
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
        var isValid = true
        
        recipientInputState.hasError = false
        ibanInputState.hasError = false
        amountInputState.hasError = false
        paymentPurposeInputState.hasError = false
        
        isValid = isRecipientValid() && isIBANValid() && isAmountValid() && isPaymentPurposeValid()
        
        return isValid
    }
    
    private func isRecipientValid() -> Bool {
        guard !recipientInputState.text.trimmingCharacters(in: .whitespaces).isEmpty else {
            recipientInputState.hasError = true
            recipientInputState.errorMessage = viewModel.model.strings.emptyCheckErrorMessage
            return false
        }
        
        return true
    }
    
    private func isIBANValid() -> Bool {
        guard !ibanInputState.text.trimmingCharacters(in: .whitespaces).isEmpty else {
            ibanInputState.hasError = true
            ibanInputState.errorMessage = viewModel.model.strings.ibanErrorMessage
            return false
        }
        
        guard ibanValidator.isValid(iban: ibanInputState.text) else {
            ibanInputState.hasError = true
            ibanInputState.errorMessage = viewModel.model.strings.ibanCheckErrorMessage
            return false
        }
        
        return true
    }
    
    private func isAmountValid() -> Bool {
        if amountInputState.text.trimmingCharacters(in: .whitespaces).isEmpty || amountToPay.value <= 0 {
            amountInputState.hasError = true
            amountInputState.errorMessage = viewModel.model.strings.emptyCheckErrorMessage
            return false
        } else {
            return true
        }
    }
    
    private func isPaymentPurposeValid() -> Bool {
        guard !paymentPurposeInputState.text.trimmingCharacters(in: .whitespaces).isEmpty else {
            paymentPurposeInputState.hasError = true
            paymentPurposeInputState.errorMessage = viewModel.model.strings.emptyCheckErrorMessage
            return false
        }
        
        return true
    }
    
    private struct Constants {
        static let emptyString = ""
        static let stackSpacingZero = 0.0
        static let bannerVerticalPadding = 16.0
        static let bannerDismissDelay = 0.3
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
