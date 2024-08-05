//
//  SkontoAmountToPayView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol SkontoAmountViewDelegate: AnyObject {
    func textFieldPriceChanged(editedText: String)
}

class SkontoAmountToPayView: UIView {
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
        containerView.addSubview(stackView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.padding),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                        constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                         constant: -Constants.padding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                       constant: -Constants.padding)
        ])
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

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.bounds.contains(point), isEditable else {
            return super.hitTest(point, with: event)
        }

        return textField
    }
}

extension SkontoAmountToPayView: PriceTextFieldDelegate {
    func priceTextField(_ textField: PriceTextField, didChangePrice editedText: String) {
        self.delegate?.textFieldPriceChanged(editedText: editedText)
    }
}

private extension SkontoAmountToPayView {
    enum Constants {
        static let padding: CGFloat = 12
        static let stackViewSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 8
    }
}
