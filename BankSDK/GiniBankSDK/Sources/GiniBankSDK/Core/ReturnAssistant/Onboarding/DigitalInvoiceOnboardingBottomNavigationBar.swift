//
//  DigitalInvoiceOnboardingBottomNavigationBar.swift
//  
//
//  Created by David Vizaknai on 10.02.2023.
//

import UIKit
import GiniCaptureSDK

final class DigitalInvoiceOnboardingBottomNavigationBar: UIView {

    lazy var continueButton: MultilineTitleButton = {
        let button = MultilineTitleButton()

        return button
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
        let configuration = GiniBankConfiguration.shared

        addSubview(continueButton)
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
        continueButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        continueButton.configure(with: configuration.primaryButtonConfiguration)
        continueButton.isAccessibilityElement = true
        continueButton.translatesAutoresizingMaskIntoConstraints = false

        let continueButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.donebutton",
                                                                           comment: "title for the done button on the digital invoice onboarding screen")
        continueButton.setTitle(continueButtonTitle, for: .normal)
        continueButton.accessibilityValue = continueButtonTitle
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            continueButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonSize.width),
            continueButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height),
            continueButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            continueButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.horizontalPadding)
        ])
    }
}

extension DigitalInvoiceOnboardingBottomNavigationBar {
    private enum Constants {
        static let buttonSize = CGSize(width: 170, height: 50)
        static let verticalPadding: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
    }
}
