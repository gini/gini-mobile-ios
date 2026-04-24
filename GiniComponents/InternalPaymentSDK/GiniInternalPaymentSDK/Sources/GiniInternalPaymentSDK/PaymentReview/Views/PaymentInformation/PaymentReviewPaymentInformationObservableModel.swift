//
//  PaymentReviewPaymentInformationObservableModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI
import GiniUtilites

/** Identifies which payment form field is currently focused.
 Stored in the observable model so focus can be restored after orientation changes recreate the view.
 */
enum ActivePaymentField: Equatable {
    case recipient
    case iban
    case amount
    case paymentPurpose
}

final class PaymentReviewPaymentInformationObservableModel: ObservableObject {
    
    private let ibanValidator = IBANValidator()

    /**
     Tracks which field was focused before the view was recreated (e.g. after rotation),
     so the keyboard can be restored in the new layout.
     */
    var activeField: ActivePaymentField? = nil

    /**
     Set to `true` while the view is on screen. Used to distinguish a rotation (view
     disappears quickly) from the user explicitly dismissing the keyboard (view stays visible).
     */
    var isViewVisible: Bool = false

    /**
     Tracks whether the amount field is currently focused.
     Published so the outer layout can observe it and show a full-width Done toolbar in landscape.
     */
    @Published var isAmountFieldFocused: Bool = false

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
    
    var isFieldsLocked: Bool {
        model.configuration.banksPicker.lockedFields
    }
    
    var lockIcon: Image? {
        isFieldsLocked ? Image(uiImage: model.configuration.banksPicker.lockIcon) : nil
    }
    
    var shouldShowBrandedView: Bool {
        model.shouldShowBrandedView
    }
    
    var poweredByGiniViewModel: PoweredByGiniViewModel {
        model.poweredByGiniViewModel
    }
    
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
            recipientError = model.strings.fieldErrors.emptyCheck
            return false
        }
        recipientError = nil
        return true
    }
    
    func validateIBAN(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            ibanError = model.strings.fieldErrors.iban
            return false
        }
        
        guard ibanValidator.isValid(iban: text) else {
            ibanError = model.strings.fieldErrors.ibanCheck
            return false
        }
        
        ibanError = nil
        return true
    }
    
    func validateAmount(_ text: String, amount: Decimal) -> Bool {
        if text.trimmingCharacters(in: .whitespaces).isEmpty || amount <= 0 {
            amountError = model.strings.fieldErrors.emptyCheck
            return false
        }
        amountError = nil
        return true
    }
    
    func validatePaymentPurpose(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            paymentPurposeError = model.strings.fieldErrors.emptyCheck
            return false
        }
        paymentPurposeError = nil
        return true
    }
    
    func validateAllFields() -> Bool {
        let recipientValid = validateRecipient(recipientInputState.text)
        let ibanValid = validateIBAN(ibanInputState.text)
        let amountValid = validateAmount(amountInputState.text, amount: amountToPay.value)
        let purposeValid = validatePaymentPurpose(paymentPurposeInputState.text)
        return recipientValid && ibanValid && amountValid && purposeValid
    }

    func buildPaymentInfo() -> PaymentInfo {
        PaymentInfo(sourceDocumentLocation: model.document?.links.document.absoluteString,
                    recipient: recipientInputState.text,
                    iban: ibanInputState.text,
                    amount: amountToPay.extractionString,
                    purpose: paymentPurposeInputState.text,
                    paymentUniversalLink: selectedPaymentProvider.universalLinkIOS,
                    paymentProviderId: selectedPaymentProvider.id)
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
    
    // MARK: - Focus / field-state helpers (moved here for testability)

    /**
     Handles a focus-change event for a generic text field.
     When the field gains focus its error state is cleared; when it loses focus the field is
     re-validated and, if invalid, the error message is announced to VoiceOver.
     */
    func handleFocusChange(isFocused: Bool,
                           inputState: ReferenceWritableKeyPath<PaymentReviewPaymentInformationObservableModel, GiniInputFieldState>,
                           validate: (String) -> Bool,
                           error: KeyPath<PaymentReviewPaymentInformationObservableModel, String?>) {
        if isFocused {
            self[keyPath: inputState].hasError = false
        } else {
            let text = self[keyPath: inputState].text
            self[keyPath: inputState].hasError = !validate(text)
            self[keyPath: inputState].errorMessage = self[keyPath: error]
            if self[keyPath: inputState].hasError, let msg = self[keyPath: error] {
                UIAccessibility.post(notification: .announcement, argument: msg)
            }
        }
    }

    /**
     Handles a focus-change event specific to the amount field.
     On focus-gained the raw numeric value is shown; on focus-lost the value is re-formatted,
     validated, and any error is announced to VoiceOver.
     */
    func handleAmountFocusChange(isFocused: Bool) {
        if isFocused {
            amountInputState.text = amountToPay.stringWithoutSymbol ?? ""
        } else {
            if !amountInputState.text.isEmpty,
               let decimalAmount = amountInputState.text.decimal() {
                amountToPay.value = decimalAmount
                if decimalAmount > 0, let amountString = amountToPay.string {
                    amountInputState.text = amountString
                } else {
                    amountInputState.text = ""
                }
            }
            amountInputState.hasError = !validateAmount(amountInputState.text, amount: amountToPay.value)
            amountInputState.errorMessage = amountError
            if amountInputState.hasError, let errorMessage = amountError {
                UIAccessibility.post(notification: .announcement, argument: errorMessage)
            }
        }
    }

    /**
     Handles a text change in the amount field: clears the error flag and updates
     both the displayed text and the `amountToPay` value if the input is parsable.
     */
    func handleAmountTextChange(updatedText: String) {
        amountInputState.hasError = false
        if let result = adjustAmountValue(text: updatedText) {
            amountInputState.text = result.adjustedText
            amountToPay.value = result.newValue
        }
    }

    /**
     Returns the visual state for a text field: `.error` when `hasError` is set,
     `.focused` when this field is the currently-active field, otherwise `.normal`.
     */
    func fieldState(for field: ActivePaymentField, hasError: Bool) -> GiniTextFieldState {
        if hasError { return .error }
        if activeField == field { return .focused }
        return .normal
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
        
        // Subscribe to payment provider changes
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
