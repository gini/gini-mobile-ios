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
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        return button
    }()

    // MARK: Temporary remove help action
//    private lazy var helpButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Help", for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        button.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)
//        return button
//    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Back", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, proceedButton])
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
    
    private var proceedAction: (() -> Void)?
    // MARK: Temporary remove help action
//    private var helpAction: (() -> Void)?
    private var backAction: (() -> Void)?

    init(proceedAction: (() -> Void)?,
         backAction: (() -> Void)?) {
        self.proceedAction = proceedAction
        self.backAction = backAction
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

    func setProceedButtonState(enabled: Bool) {
        proceedButton.isEnabled = enabled
    }

    func updateDiscountValue(with discount: String?) {
        skontoBadgeLabel.text = discount
    }

    func updateDiscountBadge(enabled: Bool) {
        skontoBadgeView.isHidden = !enabled
    }

    private func setupView() {
        addSubview(proceedButton)
        addSubview(totalLabel)
        addSubview(totalValueLabel)
        addSubview(skontoBadgeView)
        addSubview(buttonsStackView)
        skontoBadgeView.addSubview(skontoBadgeLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding / 2),
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            totalValueLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor,
                                                 constant: Constants.padding / 2),
            totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            skontoBadgeView.centerYAnchor.constraint(equalTo: totalValueLabel.centerYAnchor),
            skontoBadgeView.leadingAnchor.constraint(equalTo: totalValueLabel.trailingAnchor,
                                                     constant: Constants.badgeSpacing),
            skontoBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,
                                                     constant: -Constants.padding),

            skontoBadgeLabel.topAnchor.constraint(equalTo: skontoBadgeView.topAnchor,
                                                  constant: Constants.badgeVerticalPadding),
            skontoBadgeLabel.bottomAnchor.constraint(equalTo: skontoBadgeView.bottomAnchor,
                                                     constant: -Constants.badgeVerticalPadding),
            skontoBadgeLabel.leadingAnchor.constraint(equalTo: skontoBadgeView.leadingAnchor,
                                                      constant: Constants.badgeHorizontalPadding),
            skontoBadgeLabel.trailingAnchor.constraint(equalTo: skontoBadgeView.trailingAnchor,
                                                       constant: -Constants.badgeHorizontalPadding),

            buttonsStackView.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: Constants.padding),
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

    // MARK: Temporary remove help action
//    @objc private func helpButtonClicked() {
//        helpAction?()
//    }
    
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
    }
}

