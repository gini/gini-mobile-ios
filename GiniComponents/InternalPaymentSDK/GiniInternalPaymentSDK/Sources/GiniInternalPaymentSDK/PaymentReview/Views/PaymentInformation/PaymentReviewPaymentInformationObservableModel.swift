//
//  PaymentReviewPaymentInformationObservableModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI
import GiniUtilites

/**
 Identifies which payment form field is currently focused.
 Stored in the observable model so focus can be restored after orientation changes recreate the view.
 */
enum ActivePaymentField: Hashable {
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
    @Published var activeField: ActivePaymentField? = nil

    /**
     Back-reference so the view's focus handler can read `isDismissingForRotation`
     to tell a rotation teardown from a user dismiss.
     */
    weak var parentModel: PaymentReviewObservableModel?

    /**
     Tracks whether the amount field is currently focused.
     Published so the outer layout can observe it and show a full-width Done toolbar in landscape.
     */
    @Published var isAmountFieldFocused: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var amountErrorClearTask: Task<Void, Never>?
    
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

    /**
     Tint for the keyboard Done button. Supplied by the host SDK via
     PaymentReviewContainerConfiguration so it stays decoupled from the
     primary/Pay button styling.
     */
    var keyboardDoneButtonTintColor: Color {
        Color(uiColor: model.configuration.keyboardDoneButtonTintColor)
    }

    /**
     UIKit variant of `keyboardDoneButtonTintColor`, consumed by `GiniDoneAccessoryView`
     (a UIToolbar-based `inputAccessoryView`) which needs a `UIColor` rather than SwiftUI `Color`.
     */
    var keyboardDoneButtonTintUIColor: UIColor {
        model.configuration.keyboardDoneButtonTintColor
    }

    let model: PaymentReviewContainerViewModel
    
    init(model: PaymentReviewContainerViewModel) {
        self.model = model
        self.extractions = model.extractions ?? []
        self.selectedPaymentProvider = model.selectedPaymentProvider
        
        setupBindings()
    }
    
    deinit {
        amountErrorClearTask?.cancel()
        cancellables.removeAll()
    }
    
    func validateRecipient(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            recipientError = model.strings.fieldErrors.recipient
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
            amountError = model.strings.fieldErrors.amount
            return false
        }
        amountError = nil
        return true
    }
    
    func validatePaymentPurpose(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            paymentPurposeError = model.strings.fieldErrors.purpose
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
    
    /**
     - Note: The `toPrice` call enforces a maximum of 7 integer digits.
       Amounts with more digits are rejected and `nil` is returned, leaving the field unchanged.
     */
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
     On focus-lost the field is re-validated and, if invalid, the error message is announced
     to VoiceOver. Error clearing on focus-gain is intentionally deferred to text-change
     (see `clearErrorOnTextChange(for:)`) to avoid a layout-height change while the keyboard
     is animating in, which would cause the bottom-sheet detent to update and dismiss the keyboard.
     */
    func handleFocusChange(isFocused: Bool,
                           inputState: ReferenceWritableKeyPath<PaymentReviewPaymentInformationObservableModel, GiniInputFieldState>,
                           validate: (String) -> Bool,
                           error: KeyPath<PaymentReviewPaymentInformationObservableModel, String?>) {
        if !isFocused {
            let text = self[keyPath: inputState].text
            self[keyPath: inputState].hasError = !validate(text)
            self[keyPath: inputState].errorMessage = self[keyPath: error]
            if self[keyPath: inputState].hasError, let msg = self[keyPath: error] {
                UIAccessibility.post(notification: .announcement, argument: msg)
            }
        }
    }

    /**
     Clears the error state for a text field when its text changes while the field is not focused.
     Called from `onChange(of: text)` in the view, guarded by a focus check, so it only runs
     for programmatic text changes (e.g. population on load) — never while the user is actively
     typing. Clearing error during typing would trigger a `.error → .focused` style transition
     inside `GiniTextFieldStyle`, causing SwiftUI to replace the underlying `UITextField` and
     dismiss the keyboard.
     */
    func clearErrorOnTextChange(for inputState: ReferenceWritableKeyPath<PaymentReviewPaymentInformationObservableModel, GiniInputFieldState>) {
        guard self[keyPath: inputState].hasError else { return }
        self[keyPath: inputState].hasError = false
        self[keyPath: inputState].errorMessage = nil
    }

    /**
     Handles a focus-change event specific to the amount field.
     On focus-gained the raw numeric value is shown; on focus-lost the value is re-formatted,
     validated, and any error is announced to VoiceOver.
     Error clearing on focus-gain is deferred to `handleAmountTextChange` (via `onChange`)
     to keep the layout height stable while the keyboard animates in. For the rare edge case
     where the text is already in raw format and no `onChange` fires, error clearing is
     scheduled after the keyboard animation completes.
     */
    func handleAmountFocusChange(isFocused: Bool) {
        if isFocused {
            /// Only strip the currency symbol from the displayed text when there is a
            /// positive amount. For zero / unset values the text is already empty and
            /// a programmatic change from "" to "0,00" inside a Task can race with
            /// UIKit establishing first-responder, causing the field to briefly lose
            /// focus, re-trigger the validation path, and show the error again.
            if amountToPay.value > 0, let rawText = amountToPay.stringWithoutSymbol {
                if rawText != amountInputState.text {
                    amountInputState.text = rawText
                } else {
                    /// Text is already in raw format — no onChange fires.
                    /// Clear the error after the keyboard animation completes to avoid
                    /// a height change that would conflict with keyboard appearance.
                    clearAmountErrorAfterKeyboardAppears()
                }
            }
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
            let wasAlreadyInError = amountInputState.hasError
            amountInputState.hasError = !validateAmount(amountInputState.text, amount: amountToPay.value)
            amountInputState.errorMessage = amountError
            // Only announce when the error is newly introduced — not on a repeat call
            // (e.g. the Done button triggers handleAmountFocusChange directly and then
            // focusedField = nil triggers a second call via onChange).
            if amountInputState.hasError, !wasAlreadyInError, let errorMessage = amountError {
                UIAccessibility.post(notification: .announcement, argument: errorMessage)
            }
        }
    }

    /**
     Handles a text change in the amount field: updates both the displayed text and the
     `amountToPay` value if the input is parsable.

     Error clearing is intentionally removed from this method. The view's
     `onChange(of: amountInputState.text)` only calls `clearErrorOnTextChange` when the
     amount field is **not** focused, which prevents the `.error → .focused` style
     transition while the user is actively typing and avoids keyboard dismissal.
     */
    func handleAmountTextChange(updatedText: String) {
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
    
    private func clearAmountErrorAfterKeyboardAppears() {
        amountErrorClearTask?.cancel()
        amountErrorClearTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(Constants.keyboardAnimationDelay))
            guard !Task.isCancelled, let self, self.isAmountFieldFocused else { return }
            self.applyAmountErrorClear()
        }
    }

    func applyAmountErrorClear() {
        amountInputState.hasError = false
        amountInputState.errorMessage = nil
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
    
    private func extractValuesFromExtractions() -> (recipient: String, iban: String, amount: String, purpose: String) {
        let recipient = extractions.first(where: { $0.name == "payment_recipient" })?.value ?? ""
        let iban = extractions.first(where: { $0.name == "iban" })?.value.uppercased() ?? ""
        let purpose = extractions.first(where: { $0.name == "payment_purpose" })?.value ?? ""
        let amountString = extractions.first(where: { $0.name == "amount_to_pay" })?.value ?? ""

        return (recipient: recipient, iban: iban, amount: amountString, purpose: purpose)
    }

    private func extractValuesFromPaymentInfo(_ paymentInfo: PaymentInfo) -> (recipient: String, iban: String, amount: String, purpose: String) {
        let recipient = paymentInfo.recipient
        let iban = paymentInfo.iban.uppercased()
        let purpose = paymentInfo.purpose
        let amountString = paymentInfo.amount

        return (recipient: recipient, iban: iban, amount: amountString, purpose: purpose)
    }

    private struct Constants {
        /// Approximate duration of the iOS keyboard appearance animation.
        /// Used to defer error-clearing for the amount field in the edge case where
        /// no text-change fires on focus-gain, ensuring the height change does not
        /// conflict with keyboard presentation in bottom-sheet mode.
        static let keyboardAnimationDelay = 0.35
    }
}
