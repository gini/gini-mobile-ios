//
//  PriceLabelView.swift
//  
//
//  Created by David Vizaknai on 07.03.2023.
//

import GiniCaptureSDK
import UIKit

protocol PriceLabelViewDelegate: AnyObject {
    func showCurrencyPicker(on view: UIView)
    func priceLabelViewTextFieldDidChange(on: PriceLabelView)
}

final class PriceLabelView: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .GiniBank.dark6
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.unitPrice",
                                                             comment: "Unit price")
        label.text = title
        label.accessibilityValue = title
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.font = configuration.textStyleFonts[.body]
        textField.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.keyboardType = .numberPad
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6).uiColor()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    var priceValue: Decimal {
        get {
            guard let value = priceTextField.text, let decimal = decimal(from: value) else { return 0 }
            return decimal
        }
        set {
            var sign = ""
            if newValue < 0 {
                sign = "- "
            }
            let string = sign + (Price.stringWithoutSymbol(from: abs(newValue)) ?? "")
            priceTextField.text = string
            priceTextField.accessibilityValue = string
        }
    }

    var currencyValue: String {
        get {
            return currencyLabel.text?.lowercased() ?? ""
        }
        set {
            currencyLabel.text = newValue.uppercased()
            currencyLabel.accessibilityValue = newValue.uppercased()
        }
    }

    weak var delegate: PriceLabelViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4).uiColor()
        layer.cornerRadius = Constants.cornerRadius
        addSubview(titleLabel)
        addSubview(priceTextField)
        addSubview(currencyLabel)
    }

    @objc
    private func showCurrencyPicker() {
        delegate?.showCurrencyPicker(on: currencyLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),

            priceTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.labelPadding),
            priceTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            priceTextField.trailingAnchor.constraint(equalTo: currencyLabel.leadingAnchor,
                                                     constant: -Constants.padding),
            priceTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),

            currencyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),
            currencyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            currencyLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constants.padding)
        ])
    }

    private func decimal(from priceString: String) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.currencySymbol = ""
        return formatter.number(from: priceString)?.decimalValue
    }
}

// MARK: - UITextFieldDelegate
extension PriceLabelView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            // Limit length to 7 digits
            let onlyDigits = String(updatedText
                .trimmingCharacters(in: .whitespaces)
                .filter { c in c != "," && c != "."}
                .prefix(7))

            if let decimal = Decimal(string: onlyDigits) {
                let decimalWithFraction = decimal / 100

                if let newAmount = Price.stringWithoutSymbol(from: decimalWithFraction)?
                                        .trimmingCharacters(in: .whitespaces) {
                    // Save the selected text range to restore the cursor position after replacing the text
                    let selectedRange = textField.selectedTextRange

                    textField.text = newAmount

                    delegate?.priceLabelViewTextFieldDidChange(on: self)
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
}

private extension PriceLabelView {
    enum Constants {
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 4
    }
}
