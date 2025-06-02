//
//  SkontoAmountToPayView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

protocol SkontoAmountViewDelegate: AnyObject {
    func textFieldPriceChanged(editedText: String)
    func textFieldTapped()
}

class SkontoAmountToPayView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleLabelText
        label.numberOfLines = 1
        label.enableScaling()
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: PriceTextField = {
        let textField = PriceTextField()
        textField.priceDelegate = self
        textField.text = textFieldInitialText
        textField.textColor = .giniColorScheme().text.primary.uiColor()
        textField.font = configuration.textStyleFonts[.body]
        textField.borderStyle = .none
        textField.keyboardType = .numberPad
        textField.isUserInteractionEnabled = isEditable
        textField.adjustsFontForContentSizeCategory = true
        textField.adjustsFontSizeToFitWidth = true
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.text = currencyLabelText
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.font = configuration.textStyleFonts[.body]
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, currencyLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.giniColorScheme().textField.border.uiColor().cgColor
        view.layer.borderWidth = isEditable ? 1 : 0
        view.layer.cornerRadius = Constants.cornerRadius
        view.isAccessibilityElement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var validationLabelContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(validationLabel)
        return container
    }()

    private lazy var validationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .giniColorScheme().textField.supportingError.uiColor()
        label.font = configuration.textStyleFonts[.caption1]
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [containerView, validationLabelContainer])
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let titleLabelText: String
    private let textFieldInitialText: String
    private let currencyLabelText: String
    private var isEditable: Bool
    private let configuration = GiniBankConfiguration.shared

    /// This is needed to avoid the circular reference between this element and its container
    private var privateInputAccessoryView: UIView?

    override var inputAccessoryView: UIView? {
        get {
            privateInputAccessoryView
        }

        set {
            privateInputAccessoryView = newValue
            textField.inputAccessoryView = newValue
        }
    }

    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }

    weak var delegate: SkontoAmountViewDelegate?

    init(title: String,
         price: Price,
         isEditable: Bool = true) {
        self.titleLabelText = title
        self.textFieldInitialText = price.localizedStringWithCurrencyCode ?? ""
        self.currencyLabelText = price.currencyCode.uppercased()
        self.isEditable = isEditable
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().textField.background.uiColor()
        addSubview(mainStackView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,
                                            constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                 constant: -Constants.padding),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                           constant: Constants.padding),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                               constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                constant: -Constants.padding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                              constant: -Constants.padding),

            validationLabel.topAnchor.constraint(equalTo: validationLabelContainer.topAnchor),
            validationLabel.leadingAnchor.constraint(equalTo: validationLabelContainer.leadingAnchor,
                                                     constant: Constants.padding),
            validationLabel.trailingAnchor.constraint(equalTo: validationLabelContainer.trailingAnchor,
                                                      constant: -Constants.padding),
            validationLabel.bottomAnchor.constraint(equalTo: validationLabelContainer.bottomAnchor)
        ])
    }

    func configure(isEditable: Bool,
                   price: Price,
                   accessibilityValue: String) {
        if isEditable {
            textField.text = price.localizedStringWithoutCurrencyCode ?? ""
        } else {
            textField.text = price.localizedStringWithCurrencyCode ?? ""
        }
        self.isEditable = isEditable
        containerView.layer.borderWidth = isEditable ? 1 : 0
        containerView.accessibilityValue = accessibilityValue
        textField.isUserInteractionEnabled = isEditable
        currencyLabel.isHidden = !isEditable
    }

    func updateValidationMessage(_ message: String) {
        guard validationLabel.isHidden else {
            return
        }
        
        UIAccessibility.post(notification: .announcement, argument: message)
        validationLabel.text = message
        validationLabel.isHidden = false
    }

    func hideValidationMessage() {
        validationLabel.text = ""
        validationLabel.isHidden = true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.bounds.contains(point), isEditable else {
            return super.hitTest(point, with: event)
        }

        return textField
    }
}

extension SkontoAmountToPayView: PriceTextFieldDelegate {
    func priceTextFieldTapped() {
        delegate?.textFieldTapped()
    }

    func priceTextField(_ textField: PriceTextField, didChangePrice editedText: String) {
        delegate?.textFieldPriceChanged(editedText: editedText)
    }
}

private extension SkontoAmountToPayView {
    enum Constants {
        static let padding: CGFloat = 12
        static let stackViewSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 8
    }
}
