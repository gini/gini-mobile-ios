//
//  CustomSkontoBottomNavigationBar.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniBankSDK

final class CustomSkontoBottomNavigationBar: UIView {

    private lazy var proceedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let title = "Proceed"
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.backgroundColor = .gray
        button.layer.cornerRadius = Constants.cornerRadius
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var helpButton: UIButton = {
        let button = UIButton()
        let title = "Help"
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.backgroundColor = .gray
        button.layer.cornerRadius = Constants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        let title = "Back"
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.backgroundColor = .gray
        button.layer.cornerRadius = Constants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, proceedButton, helpButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.padding
        return stackView
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.text = "Total"
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var skontoBadgeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var skontoBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skontoBadgeLabel)
        return view
    }()
    
    private lazy var savedAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .green
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private var proceedAction: (() -> Void)?
    private var helpAction: (() -> Void)?
    private var backAction: (() -> Void)?

    init(proceedAction: (() -> Void)?,
         backAction: (() -> Void)?,
         helpAction: (() -> Void)?) {
        self.proceedAction = proceedAction
        self.backAction = backAction
        self.helpAction = helpAction
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updatePrice(with price: String?) {
        totalValueLabel.text = price
    }

    func updateSkontoPercentageBadge(with discount: String?) {
        skontoBadgeLabel.text = discount
    }

    func updateSkontoPercentageBadgeVisibility(hidden: Bool) {
        skontoBadgeView.isHidden = hidden
    }

    func updateSkontoSavingsInfo(with text: String?) {
        savedAmountLabel.text = text
    }

    func updateSkontoSavingsInfoVisibility(hidden: Bool) {
        savedAmountLabel.isHidden = hidden
    }

    private func setupView() {
        addSubview(proceedButton)
        addSubview(totalLabel)
        addSubview(totalValueLabel)
        addSubview(skontoBadgeView)
        addSubview(buttonsStackView)
        addSubview(savedAmountLabel)
        skontoBadgeView.addSubview(skontoBadgeLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding / 2),
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            totalValueLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor,
                                                 constant: Constants.padding / 2),
            totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            savedAmountLabel.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor),
            savedAmountLabel.leadingAnchor.constraint(equalTo: totalValueLabel.leadingAnchor),

            skontoBadgeView.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            skontoBadgeView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                     constant: -Constants.padding),

            skontoBadgeLabel.topAnchor.constraint(equalTo: skontoBadgeView.topAnchor,
                                                  constant: Constants.badgeVerticalPadding),
            skontoBadgeLabel.bottomAnchor.constraint(equalTo: skontoBadgeView.bottomAnchor,
                                                     constant: -Constants.badgeVerticalPadding),
            skontoBadgeLabel.leadingAnchor.constraint(equalTo: skontoBadgeView.leadingAnchor,
                                                      constant: Constants.badgeHorizontalPadding),
            skontoBadgeLabel.trailingAnchor.constraint(equalTo: skontoBadgeView.trailingAnchor,
                                                       constant: -Constants.badgeHorizontalPadding),

            buttonsStackView.topAnchor.constraint(equalTo: savedAmountLabel.bottomAnchor, constant: Constants.padding),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -Constants.padding),
            proceedButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight)
        ])
    }

    @objc private func proceedButtonClicked() {
        proceedAction?()
    }

    @objc private func helpButtonClicked() {
        helpAction?()
    }
    
    @objc private func backButtonClicked() {
        backAction?()
    }
}

extension CustomSkontoBottomNavigationBar {
    private enum Constants {
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 24
        static let payButtonHeight: CGFloat = 50
        static let badgeHorizontalPadding: CGFloat = 6
        static let badgeVerticalPadding: CGFloat = 2
        static let badgeSpacing: CGFloat = 12
        static let cornerRadius: CGFloat = 8
    }
}

