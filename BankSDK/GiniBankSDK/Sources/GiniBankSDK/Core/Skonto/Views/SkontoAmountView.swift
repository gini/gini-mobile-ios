//
//  SkontoAmountView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol SkontoAmountViewDelegate: AnyObject {
    func textFieldPriceChanged(editedText: String)
}

class SkontoAmountView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleLabelText
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
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.text = currencyLabelText
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.font = configuration.textStyleFonts[.body]
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.giniColorScheme().bg.border.uiColor().cgColor
        view.layer.borderWidth = isEditable ? 1 : 0
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabelText: String
    private let textFieldInitialText: String
    private let currencyLabelText: String
    private var isEditable: Bool
    private let configuration = GiniBankConfiguration.shared
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

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().bg.inputUnfocused.uiColor()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(currencyLabel)
        setupConstraints()
        addTapGestureRecognizer()
    }

    private func setupConstraints() {
        currencyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.padding),

            currencyLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: textField.trailingAnchor,
                                                   constant: Constants.currencyLabelHorizontalPadding),
            currencyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding)
        ])
    }

    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func handleTap() {
        guard isEditable else { return }
        textField.becomeFirstResponder()
    }

    func configure(isEditable: Bool, price: Price) {
        if isEditable {
            textField.text = price.localizedStringWithoutCurrencyCode ?? ""
        } else {
            textField.text = price.localizedStringWithCurrencyCode ?? ""
        }
        self.isEditable = isEditable
        containerView.layer.borderWidth = isEditable ? 1 : 0
        textField.isUserInteractionEnabled = isEditable
        currencyLabel.isHidden = !isEditable
    }
}

extension SkontoAmountView: PriceTextFieldDelegate {
    func priceTextField(_ textField: PriceTextField, didChangePrice editedText: String) {
        self.delegate?.textFieldPriceChanged(editedText: editedText)
    }
}

private extension SkontoAmountView {
    enum Constants {
        static let padding: CGFloat = 12
        static let currencyLabelHorizontalPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 8
    }
}
