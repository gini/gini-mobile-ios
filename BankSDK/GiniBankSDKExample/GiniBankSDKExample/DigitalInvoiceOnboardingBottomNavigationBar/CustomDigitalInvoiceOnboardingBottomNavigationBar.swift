//
//  CustomDigitalInvoiceOnboardingBottomNavigationBar.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 10.02.2023.
//

import UIKit

final class CustomDigitalInvoiceOnboardingBottomNavigationBar: UIView {
    lazy var getStartedButton: UIButton = {
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
        addSubview(getStartedButton)
        backgroundColor = .blue
        getStartedButton.isAccessibilityElement = true
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false

        let getStartedButtonTitle = "Get Started"
        getStartedButton.setTitle(getStartedButtonTitle, for: .normal)
        getStartedButton.accessibilityValue = getStartedButtonTitle
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            getStartedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            getStartedButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonSize.width),
            getStartedButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height),
            getStartedButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            getStartedButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.horizontalPadding)
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

