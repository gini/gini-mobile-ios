//
//  PaymentReviewViewController+UITextFieldDelegate.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - UITextFieldDelegate

extension PaymentReviewViewController: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     Updates amoutToPay, formated string with a currency and removes "0.00" value
     */
    func updateAmoutToPayWithCurrencyFormat() {
        if amountTextFieldView.textField.hasText, let amountFieldText = amountTextFieldView.text {
            if let priceValue = decimal(from: amountFieldText ) {
                amountToPay.value = priceValue
                if priceValue > 0 {
                    let amountToPayText = amountToPay.string
                    amountTextFieldView.text = amountToPayText
                } else {
                    amountTextFieldView.text = ""
                }
            }
        }
    }
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        applySelectionStyle(textFieldViewWithTag(tag: textField.tag))

        // remove currency symbol and whitespaces for edit mode
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            hideErrorLabel(textFieldTag: fieldIdentifier)

            if fieldIdentifier == .amountFieldTag {
                let amountToPayText = amountToPay.stringWithoutSymbol
                amountTextFieldView.text = amountToPayText
            }
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        // add currency format when edit is finished
        if TextFieldType(rawValue: textField.tag) == .amountFieldTag {
            updateAmoutToPayWithCurrencyFormat()
        }
        validateTextField(textField.tag)
        if TextFieldType(rawValue: textField.tag) == .ibanFieldTag {
            if textField.text == lastValidatedIBAN {
                showIBANValidationErrorIfNeeded()
            }
        }
        disablePayButtonIfNeeded()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if TextFieldType(rawValue: textField.tag) == .amountFieldTag,
           let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            // Limit length to 7 digits
            let onlyDigits = String(updatedText
                                        .trimmingCharacters(in: .whitespaces)
                                        .filter { c in c != "," && c != "."}
                                        .prefix(7))

            if let decimal = Decimal(string: onlyDigits) {
                let decimalWithFraction = decimal / 100

                if let newAmount = Price.stringWithoutSymbol(from: decimalWithFraction)?.trimmingCharacters(in: .whitespaces) {
                    // Save the selected text range to restore the cursor position after replacing the text
                    let selectedRange = textField.selectedTextRange

                    textField.text = newAmount
                    amountToPay.value = decimalWithFraction

                    // Move the cursor position after the inserted character
                    if let selectedRange = selectedRange {
                        let countDelta = newAmount.count - text.count
                        let offset = countDelta == 0 ? 1 : countDelta
                        textField.moveSelectedTextRange(from: selectedRange.start, to: offset)
                    }
                }
            }
            disablePayButtonIfNeeded()
            return false
           }
        return true
    }
}
