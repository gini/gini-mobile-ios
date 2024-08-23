//
//  OrderDetailView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

class OrderDetailView: UIStackView {

    public static var textFields = [String: UITextField]()
    private static var amountTextField = UITextField()
    public var amountToPay = Price(value: 0, currencyCode: "EUR")

    convenience init(_ items: [(String, String)]) {
        Self.textFields.removeAll()
        self.init(arrangedSubviews: items.map { Self.view(for: $0) })

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = Constants.verticalSpacing

        Self.amountTextField.delegate = self
    }

    private class func view(for text: (String, String)) -> UIView {

        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        horizontalStackView.spacing = 0

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text.0
        label.numberOfLines = 0
        label.textAlignment = .left
        label.widthAnchor.constraint(equalToConstant: Constants.labelWidth).isActive = true
        horizontalStackView.addArrangedSubview(label)

        let textField = UITextField()
        textFields[text.0] = textField

        if text.0 == NSLocalizedString(Fields.amountToPay.rawValue, comment: "") {
            amountTextField = textField
        }

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = text.1
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: UIFont.labelFontSize)
        horizontalStackView.addArrangedSubview(textField)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.addSubview(horizontalStackView)

        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .separator
        containerView.addSubview(bottomLine)

        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.paddingLeadingTrailing),
            horizontalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.paddingLeadingTrailing),
            horizontalStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.paddingTopBottom),
            horizontalStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.paddingTopBottom),

            bottomLine.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            bottomLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.paddingLeadingTrailing),
            bottomLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.separatorHeight)
        ])
        return containerView
    }
}

// MARK: - UITextFieldDelegate

extension OrderDetailView: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     Updates amoutToPay, formated string with a currency and removes "0.00" value
     */
    func updateAmoutToPayWithCurrencyFormat() {
        let textField = Self.amountTextField
        if textField.hasText, let text = textField.text {
            if let priceValue = text.toDecimal() {
                amountToPay.value = priceValue
                textField.text = priceValue > 0 ? amountToPay.string : ""
            }
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // remove currency symbol and whitespaces for edit mode
        let amountToPayText = amountToPay.stringWithoutSymbol
        Self.amountTextField.text = amountToPayText
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // add currency format when edit is finished
        updateAmoutToPayWithCurrencyFormat()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
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
            return false
           }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {}
}

extension OrderDetailView {
    enum Constants {
        static let labelWidth = 92.0
        static let verticalSpacing = 1.0
        static let paddingLeadingTrailing = 16.0
        static let paddingTopBottom = 16.0
        static let separatorHeight = 0.5
    }
}
