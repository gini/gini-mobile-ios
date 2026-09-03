//
//  DigitalInvoiceAddOnListView.swift
//  
//
//  Created by David Vizaknai on 23.02.2023.
//

import GiniCaptureSDK
import UIKit

final class DigitalInvoiceAddOnListView: UIView {
    private let configuration = GiniBankConfiguration.shared
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark6,
                                    dark: .GiniBank.light6).uiColor()

        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = configuration.textStyleFonts[.bodyBold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()

        return label
    }()

    init(addOnTitle: String, addOnPrice: Price) {
        super.init(frame: .zero)

        titleLabel.text = addOnTitle
        valueLabel.text = addOnPrice.string
        titleLabel.accessibilityValue = addOnTitle
        valueLabel.accessibilityValue = addOnPrice.string
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        addSubview(valueLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.labelPadding),
            titleLabel.bottomAnchor.constraint(equalTo: valueLabel.topAnchor, constant: -Constants.labelPadding),

            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.labelPadding),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private extension DigitalInvoiceAddOnListView {
    enum Constants {
        static let labelPadding: CGFloat = 8
    }
}
