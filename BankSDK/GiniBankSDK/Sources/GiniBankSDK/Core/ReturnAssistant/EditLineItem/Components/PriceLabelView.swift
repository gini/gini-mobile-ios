//
//  PriceLabelView.swift
//  
//
//  Created by David Vizaknai on 07.03.2023.
//

import GiniCaptureSDK
import UIKit

final class PriceLabelView: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .GiniBank.dark6
        label.text = "Unit price"
        return label
    }()

    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.font = configuration.textStyleFonts[.body]
        textField.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        textField.text = "76.90"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = .GiniBank.dark6
        label.text = "EUR"
        return label
    }()

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
        layer.cornerRadius = 8
        addSubview(titleLabel)
        addSubview(priceTextField)
        addSubview(currencyLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: currencyLabel.leadingAnchor, constant: -Constants.padding),

            priceTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.labelPadding),
            priceTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            priceTextField.trailingAnchor.constraint(lessThanOrEqualTo: currencyLabel.leadingAnchor, constant: -Constants.padding),
            priceTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),

            currencyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),
            currencyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            currencyLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constants.padding)
        ])
    }
}

private extension PriceLabelView {
    enum Constants {
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 4
    }
}
