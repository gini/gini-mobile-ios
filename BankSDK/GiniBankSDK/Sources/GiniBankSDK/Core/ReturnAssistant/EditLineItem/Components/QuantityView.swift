//
//  QuantityView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

final class QuantityView: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light5).uiColor()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.quantity",
                                                             comment: "Quantity")
        label.text = title
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var quantityTextField: UITextField = {
        let textField = UITextField()
        textField.font = configuration.textStyleFonts[.body]
        textField.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()

    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.setImage(prefferedImage(named: "quantity_minus_icon"), for: .normal)
        button.addTarget(self, action: #selector(decreaseQuantity), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let minusButtonAccessibilityKey = "ginibank.digitalinvoice.edit.minus.button.accessibility"
        let descriptor = NSLocalizedStringPreferredGiniBankFormat(minusButtonAccessibilityKey,
                                                                  comment: "Decrease quantity")
        button.accessibilityLabel = descriptor
        return button
    }()

    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(prefferedImage(named: "quantity_plus_icon"), for: .normal)
        button.addTarget(self, action: #selector(increaseQuantity), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let plusButtonAccessibilityKey = "ginibank.digitalinvoice.edit.plus.button.accessibility"

        let descriptor = NSLocalizedStringPreferredGiniBankFormat(plusButtonAccessibilityKey,
                                                                  comment: "Increase quantity")
        button.accessibilityLabel = descriptor
        return button
    }()

    var quantity: Int {
        get {
            guard let value = quantityTextField.text else { return 0 }
            return Int(value) ?? 0
        }
        set {
            let newValueString = String(newValue)
            quantityTextField.text = newValueString
            notifyQuantityChange(newValue: newValueString)
        }
    }

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
        addSubview(quantityTextField)
        addSubview(buttonContainerView)
        buttonContainerView.addSubview(minusButton)
        buttonContainerView.addSubview(plusButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.leadingAnchor,
                                                 constant: -Constants.padding),

            quantityTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                   constant: Constants.textFieldTopPadding),
            quantityTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            quantityTextField.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.leadingAnchor,
                                                        constant: -Constants.padding),
            quantityTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),

            buttonContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            buttonContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),

            minusButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            minusButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            minusButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            minusButton.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -Constants.labelPadding),
            minusButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height),
            minusButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize.width),

            plusButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            plusButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            plusButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            plusButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height),
            plusButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize.width)
        ])
    }

    @objc
    private func increaseQuantity() {
        if quantity < Constants.maximumQuantity {
            quantity += 1
        }
    }

    @objc
    private func decreaseQuantity() {
        if quantity > Constants.minimumQuantity {
            quantity -= 1
        }
    }

    private func notifyQuantityChange(newValue: String) {
        /// This delay is needed to ensure that VoiceOver has finished processing the touch event from the button. Otherwise it will not be announced.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: newValue)
        }
    }
}

private extension QuantityView {
    enum Constants {
        static let cornerRadius: CGFloat = 8
        static let minimumQuantity: Int = 1
        static let maximumQuantity: Int = 1000
        static let padding: CGFloat = 12
		static let textFieldTopPadding: CGFloat = 0
        static let labelPadding: CGFloat = 4
        static let buttonSize = CGSize(width: 44, height: 44)
    }
}
