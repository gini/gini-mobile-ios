//
//  ButtonsView.swift
//  
//
//  Created by Krzysztof Kryniecki on 21/11/2022.
//

import UIKit

class ButtonsView: UIView {
    private let giniConfiguration = GiniConfiguration.shared
    lazy var secondaryButton: MultilineTitleButton = configureStackViewButton(title: secondaryButtonTitle)
    lazy var primaryButton: MultilineTitleButton = configureStackViewButton(title: primaryButtonTitle)

    private func configureStackViewButton(title: String) -> MultilineTitleButton {
        let button = MultilineTitleButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = title

        // Apply minimum height constraint
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonMinimumHeight)
        ])
        return button
    }
    private lazy var buttonsView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(primaryButton)
        stackView.addArrangedSubview(secondaryButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = Constants.verticalSpacing
        return stackView
    }()

    private let secondaryButtonTitle: String
    private let primaryButtonTitle: String

    init(secondaryButtonTitle: String, primaryButtonTitle: String) {
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryButtonTitle = primaryButtonTitle
        super.init(frame: CGRect.zero)
        addSubview(buttonsView)
        configureButtons()
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        updateStackViewAxis()
    }

    private func updateStackViewAxis() {
        buttonsView.axis = UIDevice.current.isLandscape ? .horizontal : .vertical
    }

    private func configureButtons() {
        primaryButton.configure(with: giniConfiguration.primaryButtonConfiguration)
        secondaryButton.configure(with: giniConfiguration.secondaryButtonConfiguration)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateStackViewAxis()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ButtonsView {
    enum Constants {
        static let buttonMinimumHeight: CGFloat = 50
        static let verticalSpacing: CGFloat = 12
    }
}
