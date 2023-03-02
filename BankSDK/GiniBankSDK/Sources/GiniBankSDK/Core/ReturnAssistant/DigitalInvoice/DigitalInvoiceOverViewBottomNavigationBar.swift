//
//  DigitalInvoiceOverViewBottomNavigationBar.swift
//  
//
//  Created by David Vizaknai on 02.03.2023.
//

import UIKit
import GiniCaptureSDK

final class DigitalInvoiceOverviewBottomNavigationBar: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    lazy var payButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.primaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        button.setTitle(NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.paybutton.title",
                                                                 comment: "Proceed"), for: .normal)
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
        return button
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.totalpricetitle",
                                                              comment: "Total")
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = configuration.textStyleFonts[.title1Bold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
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
        addSubview(helpButton)

        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
    }

    func setupConstraints(relatedTo view: UIView) {
        NSLayoutConstraint.activate([
            payButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.padding),
            payButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.payButtonHeight),

            totalLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constants.padding),
            totalLabel.trailingAnchor.constraint(lessThanOrEqualTo: totalValueLabel.leadingAnchor, constant: Constants.padding),

            totalValueLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constants.padding),
            totalValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalValueLabel.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -Constants.labelPadding),
            totalValueLabel.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),

            helpButton.centerYAnchor.constraint(equalTo: payButton.centerYAnchor),
            helpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            helpButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight),
            helpButton.widthAnchor.constraint(equalTo: helpButton.heightAnchor)
        ])

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.tabletWidthMultiplier),
                totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
                payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonPadding),
                totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.labelPadding)
            ])
        }
    }
}

extension DigitalInvoiceOverviewBottomNavigationBar {
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
