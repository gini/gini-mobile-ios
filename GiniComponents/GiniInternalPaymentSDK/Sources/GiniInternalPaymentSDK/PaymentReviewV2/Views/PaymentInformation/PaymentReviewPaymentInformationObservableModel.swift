//
//  PaymentReviewPaymentInformationObservableModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI
import GiniUtilites

final class PaymentReviewPaymentInformationObservableModel: ObservableObject {
    
    private let ibanValidator = IBANValidator()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var extractions: [Extraction]
    @Published var selectedPaymentProvider: PaymentProvider
    @Published var recipientError: String?
    @Published var ibanError: String?
    @Published var amountError: String?
    @Published var paymentPurposeError: String?
    
    @Published var recipientInputState = GiniInputFieldState(text: "", hasError: false)
    @Published var ibanInputState = GiniInputFieldState(text: "", hasError: false)
    @Published var amountInputState = GiniInputFieldState(text: "", hasError: false)
    @Published var paymentPurposeInputState = GiniInputFieldState(text: "", hasError: false)
    @Published var amountToPay = Price(value: 0, currencyCode: "€")
    
    private(set) var hasPopulatedFields = false
    
    let model: PaymentReviewContainerViewModel
    
    init(model: PaymentReviewContainerViewModel) {
        self.model = model
        self.extractions = model.extractions ?? []
        self.selectedPaymentProvider = model.selectedPaymentProvider
        
        setupBindings()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    func validateRecipient(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            recipientError = model.strings.emptyCheckErrorMessage
            return false
        }
        recipientError = nil
        return true
    }
    
    func validateIBAN(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            ibanError = model.strings.ibanErrorMessage
            return false
        }
        
        guard ibanValidator.isValid(iban: text) else {
            ibanError = model.strings.ibanCheckErrorMessage
            return false
        }
        
        ibanError = nil
        return true
    }
    
    func validateAmount(_ text: String, amount: Decimal) -> Bool {
        if text.trimmingCharacters(in: .whitespaces).isEmpty || amount <= 0 {
            amountError = model.strings.emptyCheckErrorMessage
            return false
        }
        amountError = nil
        return true
    }
    
    func validatePaymentPurpose(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            paymentPurposeError = model.strings.emptyCheckErrorMessage
            return false
        }
        paymentPurposeError = nil
        return true
    }
    
    func validateAllFields(recipient: String, iban: String, amount: String, amountValue: Decimal, purpose: String) -> Bool {
        let recipientValid = validateRecipient(recipient)
        let ibanValid = validateIBAN(iban)
        let amountValid = validateAmount(amount, amount: amountValue)
        let purposeValid = validatePaymentPurpose(purpose)
        
        return recipientValid && ibanValid && amountValid && purposeValid
    }
    
    func buildPaymentInfo(recipient: String, iban: String, amount: String, purpose: String) -> PaymentInfo {
        PaymentInfo(
            recipient: recipient,
            iban: iban,
            bic: "",
            amount: amount,
            purpose: purpose,
            paymentUniversalLink: selectedPaymentProvider.universalLinkIOS,
            paymentProviderId: selectedPaymentProvider.id
        )
    }
    
    func adjustAmountValue(text: String) -> (adjustedText: String, newValue: Decimal)? {
        guard let newPrice = text.toPrice(maxDigitsLength: 7),
              let newAmount = newPrice.stringWithoutSymbol else {
            return nil
        }
        
        return (newAmount, newPrice.value)
    }
    
    func populateFieldsIfNeeded() {
        guard !hasPopulatedFields else { return }
        hasPopulatedFields = true
        
        let values = getInitialFieldValues()
        recipientInputState.text = values.recipient
        ibanInputState.text = values.iban
        paymentPurposeInputState.text = values.purpose
        
        if !values.amount.isEmpty, let price = Price(extractionString: values.amount) {
            amountToPay = price
            amountInputState.text = price.string ?? ""
        }
    }
    
    func updateFieldErrorStates() {
        recipientInputState.hasError = recipientError != nil
        recipientInputState.errorMessage = recipientError
        
        ibanInputState.hasError = ibanError != nil
        ibanInputState.errorMessage = ibanError
        
        amountInputState.hasError = amountError != nil
        amountInputState.errorMessage = amountError
        
        paymentPurposeInputState.hasError = paymentPurposeError != nil
        paymentPurposeInputState.errorMessage = paymentPurposeError
    }
    
    private func getInitialFieldValues() -> (recipient: String, iban: String, amount: String, purpose: String) {
        if !extractions.isEmpty {
            return extractValuesFromExtractions()
        } else if let paymentInfo = model.paymentInfo {
            return extractValuesFromPaymentInfo(paymentInfo)
        }
        
        return ("", "", "", "")
    }
    
    private func setupBindings() {
        model.onExtractionFetched = { [weak self] () in
            Task { @MainActor in
                guard let self else { return }
                self.extractions = self.model.extractions ?? []
            }
        }
        
        /// Subscribe to payment provider changes
        model.$selectedPaymentProvider
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newProvider in
                self?.selectedPaymentProvider = newProvider
            }
            .store(in: &cancellables)
    }
    
    private func extractValuesFromExtractions() -> (String, String, String, String) {
        let recipient = extractions.first(where: { $0.name == "payment_recipient" })?.value ?? ""
        let iban = extractions.first(where: { $0.name == "iban" })?.value.uppercased() ?? ""
        let purpose = extractions.first(where: { $0.name == "payment_purpose" })?.value ?? ""
        let amountString = extractions.first(where: { $0.name == "amount_to_pay" })?.value ?? ""
        
        return (recipient, iban, amountString, purpose)
    }
    
    private func extractValuesFromPaymentInfo(_ paymentInfo: PaymentInfo) -> (String, String, String, String) {
        let recipient = paymentInfo.recipient
        let iban = paymentInfo.iban.uppercased()
        let purpose = paymentInfo.purpose
        let amountString = paymentInfo.amount
        
        return (recipient, iban, amountString, purpose)
    }
}
