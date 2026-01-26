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
    
    @State private var recipient: String = Constants.emptyString
    @State private var iban: String = Constants.emptyString
    @State private var amount: String = Constants.emptyString
    @State private var paymentPurpose: String = Constants.emptyString
    
    @State private var amountToPay: Price
    @State private var showBanner: Bool = true
    
    @FocusState private var focusedField: Field?
    
    @State private var recipientHasError: Bool = false
    @State private var ibanHasError: Bool = false
    @State private var amountHasError: Bool = false
    @State private var paymentPurposeHasError: Bool = false
    
    @State private var recipientErrorMessage: String?
    @State private var ibanErrorMessage: String?
    @State private var amountErrorMessage: String?
    @State private var paymentPurposeErrorMessage: String?
    
    @Binding var contentHeight: CGFloat
    
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
    
    init(viewModel: PaymentReviewContainerViewModel,
         contentHeight: Binding<CGFloat>,
         onBankSelectionTapped: @escaping () -> Void,
         onPayTapped: @escaping (PaymentInfo) -> Void) {
        let observableModel = PaymentReviewPaymentInformationObservableModel(model: viewModel)
        self.viewModel = observableModel
        self._contentHeight = contentHeight
        self.onBankSelectionTapped = onBankSelectionTapped
        self.onPayTapped = onPayTapped
        self.amountToPay = Price(value: 0, currencyCode: "€")
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
            }
            .padding(.horizontal, Constants.textFieldsContainerHorizontalPadding)
            .padding(.top, Constants.textFieldsContainerTopPadding)
        }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: GiniViewHeightPreferenceKey.self,
                                       value: geometry.size.height)
            }
        )
        .onPreferenceChange(GiniViewHeightPreferenceKey.self, perform: { newHeight in
            DispatchQueue.main.async {
                contentHeight = newHeight
            }
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.model.configuration.popupAnimationDuration) {
                withAnimation(.easeInOut(duration: Constants.bannerDismissDelay)) {
                    showBanner = false
                }
            }
            
            populateFields()
        }
    }
    
    // MARK: Private views
    
    @ViewBuilder
    private var infoBannerView: some View {
        HStack {
            Text(viewModel.model.strings.infoBarMessage)
                .foregroundColor(Color(viewModel.model.configuration.infoBarLabelTextColor))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.bannerVerticalPadding)
        .background(Color(viewModel.model.configuration.infoBarBackgroundColor))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    @ViewBuilder
    private var recipientTextField: some View {
        TextField(Constants.emptyString, text: $recipient, onEditingChanged: { isBegin in
            recipientHasError = isBegin ? false : !isRecipientValid()
        })
        .focused($focusedField, equals: .recipient)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.recipientFieldPlaceholder,
                                           state: fieldState(for: .recipient, hasError: recipientHasError),
                                           errorMessage: recipientErrorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
    }
    
    @ViewBuilder
    private var ibanTextField: some View {
        TextField(Constants.emptyString, text: $iban, onEditingChanged: { isBegin in
            ibanHasError = isBegin ? false : !isIBANValid()
        })
        .focused($focusedField, equals: .iban)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.ibanFieldPlaceholder,
                                           state: fieldState(for: .iban, hasError: ibanHasError),
                                           errorMessage: ibanErrorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
    }
    
    @ViewBuilder
    private var amountTextField: some View {
        TextField(Constants.emptyString, text: $amount,
                  onEditingChanged: { isBegin in
            if isBegin {
                amount = amountToPay.stringWithoutSymbol ?? Constants.emptyString
            } else {
                if !amount.isEmpty,
                   let decimalAmount = amount.decimal() {
                    amountToPay.value = decimalAmount
                    
                    if decimalAmount > 0,
                       let amountString = amountToPay.string {
                        amount = amountString
                    } else {
                        amount = Constants.emptyString
                    }
                }
                
                amountHasError = !isAmountValid()
            }
        })
        .focused($focusedField, equals: .amount)
        .onChange(of: amount) { newValue in
            adjustAmountValue(updatedText: newValue)
        }
        .keyboardType(.decimalPad)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.amountFieldPlaceholder,
                                           state: fieldState(for: .amount, hasError: amountHasError),
                                           errorMessage: amountErrorMessage,
                                           normalConfiguration: textFieldConfiguration,
                                           focusedConfiguration: focusedTextFieldConfiguration,
                                           errorConfiguration: errorTextFieldConfiguration))
    }
    
    @ViewBuilder
    private var paymentPurposeTextField: some View {
        TextField(Constants.emptyString, text: $paymentPurpose, onEditingChanged: { isBegin in
            paymentPurposeHasError = isBegin ? false : !isPaymentPurposeValid()
        })
        .focused($focusedField, equals: .paymentPurpose)
        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.usageFieldPlaceholder,
                                           state: fieldState(for: .paymentPurpose, hasError: paymentPurposeHasError),
                                           errorMessage: paymentPurposeErrorMessage,
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
            .foregroundColor(Color(selectedPaymentProviderTextColor))
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
        recipient = extractions.first(where: { $0.name == "payment_recipient" })?.value ?? Constants.emptyString
        iban = extractions.first(where: { $0.name == "iban" })?.value.uppercased() ?? Constants.emptyString
        paymentPurpose = extractions.first(where: { $0.name == "payment_purpose" })?.value ?? Constants.emptyString
        
        if let amountString = viewModel.extractions.first(where: { $0.name == "amount_to_pay" })?.value,
           let amountToPay = Price(extractionString: amountString),
           let amountToPayString = amountToPay.string {
            self.amountToPay = amountToPay
            amount = amountToPayString
        }
    }
    
    private func populateFieldsWithPaymentInfo(_ paymentInfo: PaymentInfo) {
        recipient = paymentInfo.recipient
        iban = paymentInfo.iban.uppercased()
        paymentPurpose = paymentInfo.purpose
        
        if let amountToPay = Price(extractionString: paymentInfo.amount),
           let amountToPayText = amountToPay.string {
            self.amountToPay = amountToPay
            amount = amountToPayText
        }
    }
    
    private func buildPaymentInfo() -> PaymentInfo {
        let paymentInfo = PaymentInfo(recipient: recipient,
                                      iban: iban,
                                      bic: Constants.emptyString,
                                      amount: amountToPay.extractionString,
                                      purpose: paymentPurpose,
                                      paymentUniversalLink: viewModel.selectedPaymentProvider.universalLinkIOS,
                                      paymentProviderId: viewModel.selectedPaymentProvider.id)
        return paymentInfo
    }
    
    private func adjustAmountValue(updatedText: String) {
        amountHasError = false
        
        if let newPrice = updatedText.toPrice(maxDigitsLength: 7),
           let newAmount = newPrice.stringWithoutSymbol {
            amount = newAmount
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
        
        recipientHasError = false
        ibanHasError = false
        amountHasError = false
        paymentPurposeHasError = false
        
        isValid = isRecipientValid() && isIBANValid() && isAmountValid() && isPaymentPurposeValid()
        
        return isValid
    }
    
    private func isRecipientValid() -> Bool {
        guard !recipient.trimmingCharacters(in: .whitespaces).isEmpty else {
            recipientHasError = true
            recipientErrorMessage = viewModel.model.strings.emptyCheckErrorMessage
            return false
        }
        
        return true
    }
    
    private func isIBANValid() -> Bool {
        guard !iban.trimmingCharacters(in: .whitespaces).isEmpty else {
            ibanHasError = true
            ibanErrorMessage = viewModel.model.strings.ibanErrorMessage
            return false
        }
        
        guard ibanValidator.isValid(iban: iban) else {
            ibanHasError = true
            ibanErrorMessage = viewModel.model.strings.ibanCheckErrorMessage
            return false
        }
        
        return true
    }
    
    private func isAmountValid() -> Bool {
        if amount.trimmingCharacters(in: .whitespaces).isEmpty || amountToPay.value <= 0 {
            amountHasError = true
            amountErrorMessage = viewModel.model.strings.emptyCheckErrorMessage
            return false
        } else {
            return true
        }
    }
    
    private func isPaymentPurposeValid() -> Bool {
        guard !paymentPurpose.trimmingCharacters(in: .whitespaces).isEmpty else {
            paymentPurposeHasError = true
            paymentPurposeErrorMessage = viewModel.model.strings.emptyCheckErrorMessage
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
        static let paymentProviderPickerWidth = 96.0
        static let paymentButtonHeight = 36.0
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
