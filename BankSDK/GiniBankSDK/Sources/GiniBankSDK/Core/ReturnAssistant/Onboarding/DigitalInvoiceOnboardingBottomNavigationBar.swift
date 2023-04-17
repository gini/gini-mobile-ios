//
//  DigitalInvoiceOnboardingBottomNavigationBar.swift
//  
//
//  Created by David Vizaknai on 10.02.2023.
//

import UIKit
import GiniCaptureSDK

final class DigitalInvoiceOnboardingBottomNavigationBar: UIView {

    lazy var getStartedButton: MultilineTitleButton = {
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

        addSubview(getStartedButton)
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
        getStartedButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        getStartedButton.configure(with: configuration.primaryButtonConfiguration)
        getStartedButton.isAccessibilityElement = true
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false

        let getStartedButtonTitle = NSLocalizedStringPreferredGiniBankFormat(
                                        "ginibank.digitalinvoice.onboarding.getStartedButton",
                                        comment: "title for the done button on the digital invoice onboarding screen")
        getStartedButton.setTitle(getStartedButtonTitle, for: .normal)
        getStartedButton.accessibilityValue = getStartedButtonTitle
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            getStartedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            getStartedButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonSize.width),
            getStartedButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height),
            getStartedButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            getStartedButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor,
                                                      constant: Constants.horizontalPadding)
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
