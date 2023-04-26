//
//  DigitalInvoiceBottomNavigationBar.swift
//  
//
//  Created by David Vizaknai on 02.03.2023.
//

import UIKit
import GiniCaptureSDK

final class DigitalInvoiceBottomNavigationBar: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    lazy var payButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.primaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.paybutton.title",
                                                             comment: "Proceed")
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }()

    lazy var helpButton = GiniBarButton(ofType: .help)

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.totalpricetitle",
                                                            comment: "Total")
        label.text = text
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = configuration.textStyleFonts[.title1Bold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.setContentHuggingPriority(.required, for: .vertical)
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

    func updatePrice(with price: String?) {
        totalValueLabel.text = price
    }

    func setProceedButtonState(enabled: Bool) {
        payButton.isEnabled = enabled

        if enabled {
            payButton.configure(with: configuration.primaryButtonConfiguration)
        } else {
            payButton.configure(with: configuration.secondaryButtonConfiguration)
        }
    }

    private func setupView() {
        addSubview(payButton)
        addSubview(totalLabel)
        addSubview(totalValueLabel)
        addSubview(helpButton.buttonView)
        helpButton.buttonView.translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            payButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.labelPadding),
            payButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.payButtonHeight),

            totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding/2),
            totalLabel.bottomAnchor.constraint(equalTo: totalValueLabel.topAnchor, constant: -Constants.padding/2),

            totalValueLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: Constants.padding/2),
            totalValueLabel.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -Constants.padding),

            helpButton.buttonView.centerYAnchor.constraint(equalTo: payButton.centerYAnchor),
            helpButton.buttonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            helpButton.buttonView.leadingAnchor.constraint(greaterThanOrEqualTo: payButton.trailingAnchor)
        ])

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                totalLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                totalLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                                  multiplier: Constants.tabletWidthMultiplier),
                totalValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                totalValueLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                                  multiplier: Constants.tabletWidthMultiplier),
                payButton.leadingAnchor.constraint(equalTo: totalLabel.leadingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                totalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
                totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
                totalValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
                totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
                payButton.leadingAnchor.constraint(greaterThanOrEqualTo: totalValueLabel.leadingAnchor,
                                                   constant: Constants.buttonPadding),
                payButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumPayButtonWidth)
            ])
        }
    }
}

extension DigitalInvoiceBottomNavigationBar {
    private enum Constants {
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 24
        static let buttonPadding: CGFloat = 76
        static let payButtonHeight: CGFloat = 50
        static let minimumPayButtonWidth: CGFloat = 150
        static let helpButtonHeight: CGFloat = 44
        static let helpButtonInset: CGFloat = 4
        static let tabletWidthMultiplier: CGFloat = 0.7
    }
}
