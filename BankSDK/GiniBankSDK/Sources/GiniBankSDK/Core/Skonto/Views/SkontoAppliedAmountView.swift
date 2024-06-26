//
//  SkontoAppliedAmountView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoAppliedAmountView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.amount.title",
                                                              comment: "Betrag nach Abzug")
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = "999,00"
        textField.textColor = .giniColorScheme().text.primary.uiColor()
        textField.font = configuration.textStyleFonts[.body]
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "EUR"
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.font = configuration.textStyleFonts[.body]
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.giniColorScheme().bg.border.uiColor().cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let configuration = GiniBankConfiguration.shared

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().bg.inputUnfocused.uiColor()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(currencyLabel)
        setupConstraints()
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
}

private extension SkontoAppliedAmountView {
    enum Constants {
        static let padding: CGFloat = 12
        static let currencyLabelHorizontalPadding: CGFloat = 10
    }
}
