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
    public var order: Order?

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
            textField.keyboardType = .decimalPad
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
        if textField.hasText, let text = textField.text?.replacingOccurrences(of: ".", with: "") {
            if let priceValue = text.decimal(),
               var price = order?.price {
                price.value = priceValue

                order?.amountToPay = price.extractionString
                textField.text = priceValue > 0 ? price.string : ""
            }
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // remove currency symbol and whitespaces for edit mode
        let amountToPayText = order?.price.stringWithoutSymbol ?? ""
        Self.amountTextField.text = amountToPayText
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // add currency format when edit is finished
        updateAmoutToPayWithCurrencyFormat()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
