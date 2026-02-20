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
    
    let model: PaymentReviewContainerViewModel
    
    init(model: PaymentReviewContainerViewModel) {
        self.model = model
        self.extractions = model.extractions ?? []
        self.selectedPaymentProvider = model.selectedPaymentProvider
        
        setupBindings()
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
    
    func clearValidationErrors() {
        recipientError = nil
        ibanError = nil
        amountError = nil
        paymentPurposeError = nil
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
    
    func getInitialFieldValues() -> (recipient: String, iban: String, amount: String, purpose: String) {
        if !extractions.isEmpty {
            return extractValuesFromExtractions()
        } else if let paymentInfo = model.paymentInfo {
            return extractValuesFromPaymentInfo(paymentInfo)
        }
        
        return ("", "", "", "")
    }
    
    private func setupBindings() {
        model.onExtractionFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.extractions = self?.model.extractions ?? []
            }
        }
        
        /// Subscribe to payment provider changes
        model.$selectedPaymentProvider
            .sink { [weak self] newProvider in
                self?.selectedPaymentProvider = newProvider
            }
            .store(in: &cancellables)
    }
    
    private func extractValuesFromExtractions() -> (String, String, String, String) {
        let recipient = extractions.first(where: { $0.name == "payment_recipient" })?.value ?? ""
        let iban = extractions.first(where: { $0.name == "iban" })?.value.uppercased() ?? ""
        let purpose = extractions.first(where: { $0.name == "payment_purpose" })?.value ?? ""
        
        var amountText = ""
        
        if let amountString = extractions.first(where: { $0.name == "amount_to_pay" })?.value,
           let price = Price(extractionString: amountString),
           let priceString = price.string {
            amountText = priceString
        }
        
        return (recipient, iban, amountText, purpose)
    }
    
    private func extractValuesFromPaymentInfo(_ paymentInfo: PaymentInfo) -> (String, String, String, String) {
        let recipient = paymentInfo.recipient
        let iban = paymentInfo.iban.uppercased()
        let purpose = paymentInfo.purpose
        
        var amountText = ""
        
        if let price = Price(extractionString: paymentInfo.amount),
           let priceString = price.string {
            amountText = priceString
        }
        
        return (recipient, iban, amountText, purpose)
    }
}
