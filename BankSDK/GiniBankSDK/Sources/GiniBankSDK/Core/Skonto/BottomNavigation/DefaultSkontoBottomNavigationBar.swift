//
//  DefaultSkontoBottomNavigationBar.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class DefaultSkontoBottomNavigationBar: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    private lazy var proceedButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.primaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.paybutton.title",
                                                             comment: "Proceed")
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        return button
    }()

    // MARK: Temporary remove help action
//    private lazy var helpButton: GiniBarButton = {
//        let button = GiniBarButton(ofType: .help)
//        button.buttonView.translatesAutoresizingMaskIntoConstraints = false
//        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        button.addAction(self, #selector(helpButtonClicked))
//        return button
//    }()

    private lazy var backButton: GiniBarButton = {
        let button = GiniBarButton(ofType: .back(title: ""))
        button.buttonView.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.addAction(self, #selector(backButtonClicked))
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton.buttonView, proceedButton])
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
        label.font = configuration.textStyleFonts[.body]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.title",
                                                            comment: "Total")
        label.text = text
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = configuration.textStyleFonts[.title1Bold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var skontoBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.caption1]
        label.textColor = .giniColorScheme().chips.textSuggestionEnabled.uiColor()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var skontoBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().chips.suggestionEnabled.uiColor()
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

        if enabled {
            proceedButton.configure(with: configuration.primaryButtonConfiguration)
        } else {
            proceedButton.configure(with: configuration.secondaryButtonConfiguration)
        }
    }

    func updateDiscountValue(with discount: String?) {
        skontoBadgeLabel.text = discount
    }

    func updateDiscountBadge(enabled: Bool) {
        skontoBadgeView.isHidden = !enabled
    }

    private func setupView() {
        backgroundColor = .giniColorScheme().bg.surface.uiColor()

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

extension DefaultSkontoBottomNavigationBar {
    private enum Constants {
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 24
        static let payButtonHeight: CGFloat = 50
        static let badgeHorizontalPadding: CGFloat = 6
        static let badgeVerticalPadding: CGFloat = 2
        static let badgeSpacing: CGFloat = 12
    }
}
