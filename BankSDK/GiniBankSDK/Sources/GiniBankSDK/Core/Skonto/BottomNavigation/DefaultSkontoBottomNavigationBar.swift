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
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.proceedbutton.title",
                                                             comment: "Continue to pay")
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

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.subheadline]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.title",
                                                            comment: "Total")
        label.text = text
        label.accessibilityValue = text
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = configuration.textStyleFonts[.title2Bold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var skontoBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().chips.textSuggestionEnabled.uiColor()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var skontoBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().chips.suggestionEnabled.uiColor()
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skontoBadgeLabel)
        return view
    }()

    private lazy var savingsAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().chips.suggestionEnabled.uiColor()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var dividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = .giniColorScheme().bg.divider.uiColor()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        return dividerView
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
        totalValueLabel.accessibilityValue = price
    }

    func updateDiscountValue(with discount: String?) {
        skontoBadgeLabel.text = discount
        skontoBadgeLabel.accessibilityValue = discount
    }

    func updateDiscountBadge(hidden: Bool) {
        skontoBadgeView.isHidden = hidden
    }

    func updateInvoiceSkontoSavings(with text: String?) {
        savingsAmountLabel.text = text
        savingsAmountLabel.accessibilityValue = text
    }

    func displayInvoiceSkontoSavingsBadge(hidden: Bool) {
        savingsAmountLabel.isHidden = hidden
    }

    private func setupView() {
        backgroundColor = .giniColorScheme().bg.surface.uiColor()

        addSubview(proceedButton)
        addSubview(totalLabel)
        addSubview(totalValueLabel)
        addSubview(skontoBadgeView)
        addSubview(savingsAmountLabel)
        addSubview(backButton.buttonView)
        addSubview(dividerView)
        skontoBadgeView.addSubview(skontoBadgeLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight),

            totalLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: Constants.padding),
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            totalValueLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor,
                                                 constant: Constants.totalValueLabelTopPadding),
            totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            savingsAmountLabel.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor,
                                                  constant: Constants.savingsAmountLabelTopPadding),
            savingsAmountLabel.leadingAnchor.constraint(equalTo: totalValueLabel.leadingAnchor),

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

            backButton.buttonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            backButton.buttonView.centerYAnchor.constraint(equalTo: proceedButton.centerYAnchor),

            proceedButton.topAnchor.constraint(equalTo: savingsAmountLabel.bottomAnchor,
                                               constant: Constants.proceedButtonTopPadding),
            proceedButton.leadingAnchor.constraint(equalTo: backButton.buttonView.trailingAnchor),
            proceedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            proceedButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -Constants.verticalPadding),
            proceedButton.heightAnchor.constraint(equalToConstant: Constants.proceedButtonHeight)
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
        static let verticalPadding: CGFloat = 16
        static let proceedButtonTopPadding: CGFloat = 20
        static let proceedButtonHeight: CGFloat = 50
        static let dividerViewHeight: CGFloat = 1
        static let badgeHorizontalPadding: CGFloat = 6
        static let badgeVerticalPadding: CGFloat = 2
        static let badgeSpacing: CGFloat = 12
        static let cornerRadius: CGFloat = 4
        static let totalValueLabelTopPadding: CGFloat = 4
        static let savingsAmountLabelTopPadding: CGFloat = 2
    }
}
