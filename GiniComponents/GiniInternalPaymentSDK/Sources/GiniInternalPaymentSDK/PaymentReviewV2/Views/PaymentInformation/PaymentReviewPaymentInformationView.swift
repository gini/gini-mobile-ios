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
    
    @State private var recipient: String = ""
    @State private var iban: String = ""
    @State private var amount: String = ""
    @State private var paymentPurpose: String = ""
    
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
    
    init(viewModel: PaymentReviewContainerViewModel,
         onBankSelectionTapped: @escaping () -> Void,
         onPayTapped: @escaping (PaymentInfo) -> Void) {
        let observableModel = PaymentReviewPaymentInformationObservableModel(model: viewModel)
        self.viewModel = observableModel
        self.onBankSelectionTapped = onBankSelectionTapped
        self.onPayTapped = onPayTapped
        self.amountToPay = Price(value: 0, currencyCode: "€")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showBanner {
                HStack {
                    Text(viewModel.model.strings.infoBarMessage)
                        .foregroundColor(Color(viewModel.model.configuration.infoBarLabelTextColor))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(viewModel.model.configuration.infoBarBackgroundColor))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            VStack(spacing: 8.0) {
                let textFieldConfiguration = viewModel.model.defaultStyleInputFieldConfiguration
                let focusedTextFieldConfiguration = viewModel.model.selectionStyleInputFieldConfiguration
                let errorTextFieldConfiguration = viewModel.model.errorStyleInputFieldConfiguration
                let viewModelStrings = viewModel.model.strings
                
                TextField("", text: $recipient, onEditingChanged: { isBegin in
                    recipientHasError = isBegin ? false : !isRecipientValid()
                })
                    .focused($focusedField, equals: .recipient)
                    .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.recipientFieldPlaceholder,
                                                       state: fieldState(for: .recipient, hasError: recipientHasError),
                                                       errorMessage: recipientErrorMessage,
                                                       normalConfiguration: textFieldConfiguration,
                                                       focusedConfiguration: focusedTextFieldConfiguration,
                                                       errorConfiguration: errorTextFieldConfiguration))
                
                HStack(spacing: 8.0) {
                    TextField("", text: $iban, onEditingChanged: { isBegin in
                        ibanHasError = isBegin ? false : !isIBANValid()
                    })
                        .focused($focusedField, equals: .iban)
                        .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.ibanFieldPlaceholder,
                                                           state: fieldState(for: .iban, hasError: ibanHasError),
                                                           errorMessage: ibanErrorMessage,
                                                           normalConfiguration: textFieldConfiguration,
                                                           focusedConfiguration: focusedTextFieldConfiguration,
                                                          errorConfiguration: errorTextFieldConfiguration))
                    
                    TextField("", text: $amount,
                              onEditingChanged: { isBegin in
                        if isBegin {
                            amount = amountToPay.stringWithoutSymbol ?? ""
                        } else {
                            if !amount.isEmpty,
                                let decimalAmount = amount.decimal() {
                                amountToPay.value = decimalAmount
                                
                                if decimalAmount > 0,
                                   let amountString = amountToPay.string {
                                    amount = amountString
                                } else {
                                    amount = ""
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
                
                TextField("", text: $paymentPurpose, onEditingChanged: { isBegin in
                    paymentPurposeHasError = isBegin ? false : !isPaymentPurposeValid()
                })
                    .focused($focusedField, equals: .paymentPurpose)
                    .textFieldStyle(GiniTextFieldStyle(title: viewModelStrings.usageFieldPlaceholder,
                                                       state: fieldState(for: .paymentPurpose, hasError: paymentPurposeHasError),
                                                       errorMessage: paymentPurposeErrorMessage,
                                                       normalConfiguration: textFieldConfiguration,
                                                      focusedConfiguration: focusedTextFieldConfiguration,
                                                      errorConfiguration: errorTextFieldConfiguration))
                
                if #available(iOS 15.0, *) {
                    HStack(spacing: 8.0) {
                        Button(action: {
                            onBankSelectionTapped()
                        }) {
                            HStack(spacing: 12.0) {
                                if let uiImage = UIImage(data: viewModel.selectedPaymentProvider.iconData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 36, height: 36)
                                        .cornerRadius(6.0)
                                }
                                
                                if let chevronImage = viewModel.model.configuration.chevronDownIcon,
                                    let chevronDownIconColor = viewModel.model.configuration.chevronDownIconColor {
                                    Image(uiImage: chevronImage)
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .tint(Color(chevronDownIconColor))
                                }
                            }
                            .frame(width: 96.0, height: 36.0)
                            .padding(.vertical, 10.0)
                        }
                        .background(Color(viewModel.model.secondaryButtonConfiguration.backgroundColor))
                        .cornerRadius(viewModel.model.secondaryButtonConfiguration.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: viewModel.model.secondaryButtonConfiguration.cornerRadius)
                                .stroke(Color(viewModel.model.secondaryButtonConfiguration.borderColor),
                                        lineWidth: viewModel.model.secondaryButtonConfiguration.borderWidth)
                        )
                        
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
                            .frame(height: 56.0)
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            .padding(.horizontal, 16.0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.model.configuration.popupAnimationDuration) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showBanner = false
                }
            }
            
            populateFields()
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
        recipient = extractions.first(where: { $0.name == "payment_recipient" })?.value ?? ""
        iban = extractions.first(where: { $0.name == "iban" })?.value.uppercased() ?? ""
        paymentPurpose = extractions.first(where: { $0.name == "payment_purpose" })?.value ?? ""
        
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
                                      bic: "",
                                      amount: amountToPay.extractionString,
                                      purpose: paymentPurpose,
                                      paymentUniversalLink: viewModel.selectedPaymentProvider.universalLinkIOS,
                                      paymentProviderId: viewModel.selectedPaymentProvider.id)
        return paymentInfo
    }
    
    private func adjustAmountValue(updatedText: String) {
        amountHasError = false
        
        // Limit length to 7 digits
        let onlyDigits = String(updatedText
                                    .trimmingCharacters(in: .whitespaces)
                                    .filter { c in c != "," && c != "."}
                                    .prefix(7))

        if let decimal = Decimal(string: onlyDigits) {
            let decimalWithFraction = decimal / 100

            if let newAmount = Price.stringWithoutSymbol(from: decimalWithFraction)?.trimmingCharacters(in: .whitespaces) {
                amount = newAmount
                amountToPay.value = decimalWithFraction
            }
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
}
