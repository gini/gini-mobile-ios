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
        return button
    }()

    lazy var helpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(prefferedImage(named: "help_icon_1"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.helpButtonInset,
                                              left: Constants.helpButtonInset,
                                              bottom: Constants.helpButtonInset,
                                              right: Constants.helpButtonInset)
        button.accessibilityValue = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.screenTitle",
                                                                             comment: "Help")
        return button
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.adjustsFontForContentSizeCategory = true
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.totalpricetitle",
                                                            comment: "Total")
        label.text = text
        label.accessibilityValue = text
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.adjustsFontForContentSizeCategory = true
        label.font = configuration.textStyleFonts[.title1Bold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        return label
    }()

    private lazy var totalContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
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
        totalValueLabel.accessibilityValue = price
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
        addSubview(totalContainerView)
        totalContainerView.addSubview(totalLabel)
        totalContainerView.addSubview(totalValueLabel)
        addSubview(helpButton)

        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            payButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.padding),
            payButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.payButtonHeight),

            totalContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constants.padding / 2),
            totalContainerView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -Constants.labelPadding),

            totalLabel.topAnchor.constraint(greaterThanOrEqualTo: totalContainerView.topAnchor),
            totalLabel.leadingAnchor.constraint(equalTo: totalContainerView.leadingAnchor),
            totalLabel.centerYAnchor.constraint(equalTo: totalContainerView.centerYAnchor),
            totalLabel.bottomAnchor.constraint(lessThanOrEqualTo: totalContainerView.bottomAnchor),
            totalLabel.trailingAnchor.constraint(lessThanOrEqualTo: totalValueLabel.leadingAnchor, constant: Constants.padding),

            totalValueLabel.topAnchor.constraint(equalTo: totalContainerView.topAnchor),
            totalValueLabel.trailingAnchor.constraint(equalTo: totalContainerView.trailingAnchor),
            totalValueLabel.bottomAnchor.constraint(equalTo: totalContainerView.bottomAnchor),
            totalValueLabel.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),

            helpButton.centerYAnchor.constraint(equalTo: payButton.centerYAnchor),
            helpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            helpButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight),
            helpButton.widthAnchor.constraint(equalTo: helpButton.heightAnchor)
        ])

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                totalContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                totalContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.tabletWidthMultiplier),
                payButton.leadingAnchor.constraint(equalTo: totalContainerView.leadingAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                totalContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
                totalContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
                payButton.leadingAnchor.constraint(equalTo: totalContainerView.leadingAnchor, constant: Constants.buttonPadding)
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
        static let helpButtonHeight: CGFloat = 44
        static let helpButtonInset: CGFloat = 4
        static let tabletWidthMultiplier: CGFloat = 0.7
    }
}
