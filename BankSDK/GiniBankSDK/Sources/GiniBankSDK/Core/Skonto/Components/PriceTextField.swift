//
//  PriceTextField.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol PriceTextFieldDelegate: AnyObject {
    func priceTextField(_ textField: PriceTextField, didChangePrice editedText: String)
}

class PriceTextField: UITextField, UITextFieldDelegate {
    weak var priceDelegate: PriceTextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(paste(_:))
    }

    override func paste(_ sender: Any?) {
        if let pastedText = UIPasteboard.general.string {
            let filteredText = filterAndTrimInput(pastedText)
            if let decimal = Decimal(string: filteredText) {
                let formattedText = formatDecimal(decimal)
                updateTextField(with: formattedText, originalText: self.text ?? "")
            }
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else {
            return true
        }

        let updatedText = text.replacingCharacters(in: textRange, with: string)
        let filteredText = filterAndTrimInput(updatedText)

        guard let decimal = Decimal(string: filteredText) else {
            return false
        }

        let formattedText = formatDecimal(decimal)
        updateTextField(with: formattedText, originalText: text)

        return false
    }

    private func filterAndTrimInput(_ text: String) -> String {
        return String(text.trimmingCharacters(in: .whitespaces).filter { $0.isNumber }.prefix(7))
    }

    private func formatDecimal(_ decimal: Decimal) -> String? {
        let decimalWithFraction = decimal / 100
        return Price.localizedStringWithoutCurrencyCode(from: decimalWithFraction)?.trimmingCharacters(in: .whitespaces)
    }

    private func updateTextField(with newText: String?, originalText: String) {
        guard let newText = newText else { return }
        let selectedRange = self.selectedTextRange
        self.text = newText
        priceDelegate?.priceTextField(self, didChangePrice: newText)
        adjustCursorPosition(newText: newText, originalText: originalText, selectedRange: selectedRange)
    }

    private func adjustCursorPosition(newText: String, originalText: String, selectedRange: UITextRange?) {
        guard let selectedRange = selectedRange else { return }
        let countDelta = newText.count - originalText.count
        let offset = countDelta == 0 ? 1 : countDelta
        self.moveSelectedTextRange(from: selectedRange.start, to: offset)
    }
}
