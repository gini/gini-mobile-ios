//
//  CustomDigitalInvoiceOnboardingBottomNavigationBar.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 10.02.2023.
//

import UIKit

final class CustomDigitalInvoiceOnboardingBottomNavigationBar: UIView {
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
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
        addSubview(continueButton)
        backgroundColor = .blue
        continueButton.isAccessibilityElement = true
        continueButton.translatesAutoresizingMaskIntoConstraints = false

        let continueButtonTitle = "Continue"
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

extension CustomDigitalInvoiceOnboardingBottomNavigationBar {
    private enum Constants {
        static let buttonSize = CGSize(width: 170, height: 50)
        static let verticalPadding: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
    }
}

