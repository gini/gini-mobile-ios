//
//  ButtonsView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
class ButtonsView: UIView {

    enum ButtonType {
        case primary
        case secondary
    }

    private let giniConfiguration = GiniConfiguration.shared
    lazy var secondaryButton: MultilineTitleButton = configureStackViewButton(title: secondaryButtonTitle)
    lazy var primaryButton: MultilineTitleButton = configureStackViewButton(title: primaryButtonTitle)

    private lazy var buttonsView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = Constants.verticalSpacing
        return stackView
    }()

    private let secondaryButtonTitle: String
    private let primaryButtonTitle: String
    private let buttonOrder: [ButtonType]

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(secondaryButtonTitle: String,
         primaryButtonTitle: String,
         buttonOrder: [ButtonType] = [.primary, .secondary]) {
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryButtonTitle = primaryButtonTitle
        self.buttonOrder = buttonOrder
        super.init(frame: CGRect.zero)
        setupView()
    }

    private func setupView() {
        addSubview(buttonsView)
        configureButtons()
        arrangeButtons()

        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        updateStackViewAxis()
    }

    private func arrangeButtons() {
        buttonOrder.forEach { buttonType in
            switch buttonType {
            case .primary:
                buttonsView.addArrangedSubview(primaryButton)
            case .secondary:
                buttonsView.addArrangedSubview(secondaryButton)
            }
        }
    }

    private func updateStackViewAxis() {
        buttonsView.axis = UIDevice.current.isLandscape ? .horizontal : .vertical
    }

    private func configureButtons() {
        primaryButton.configure(with: giniConfiguration.primaryButtonConfiguration)
        secondaryButton.configure(with: giniConfiguration.secondaryButtonConfiguration)
    }

    private func configureStackViewButton(title: String) -> MultilineTitleButton {
        let button = MultilineTitleButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = title

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonMinimumHeight)
        ])
        return button
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateStackViewAxis()
    }
}

private extension ButtonsView {
    enum Constants {
        static let buttonMinimumHeight: CGFloat = 50
        static let verticalSpacing: CGFloat = 12
    }
}
