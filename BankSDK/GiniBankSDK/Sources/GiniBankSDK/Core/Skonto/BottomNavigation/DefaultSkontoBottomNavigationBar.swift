//
//  DefaultSkontoBottomNavigationBar.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class DefaultSkontoBottomNavigationBar: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var proceedButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.primaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.proceedbutton.title",
                                                             comment: "Proceed")
        button.setTitle(title, for: .normal)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var helpButton: GiniBarButton = {
        let button = GiniBarButton(ofType: .help)
        button.buttonView.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.addAction(self, #selector(helpButtonClicked))
        return button
    }()

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
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.title",
                                                            comment: "Total")
        label.text = text
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.title2Bold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var totalAmountStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalLabel, totalValueLabel])
        stackView.axis = .vertical
        stackView.spacing = Constants.totalValueLabelTopPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isAccessibilityElement = true
        stackView.accessibilityLabel = "\(totalLabel.text ?? "") \(totalValueLabel.text ?? "")"
        return stackView
    }()

    private lazy var skontoBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().badge.content.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var skontoBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().badge.background.uiColor()
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
        label.textColor = .giniColorScheme().text.success.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var dividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = .giniColorScheme().bottomBar.border.uiColor()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        return dividerView
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

    func updateDiscountValue(with discount: String?) {
        skontoBadgeLabel.text = discount
    }

    func updateDiscountBadge(hidden: Bool) {
        skontoBadgeView.isHidden = hidden
    }

    func updateInvoiceSkontoSavings(with text: String?) {
        savingsAmountLabel.text = text
    }

    func displayInvoiceSkontoSavingsBadge(hidden: Bool) {
        savingsAmountLabel.isHidden = hidden
    }

    private func setupView() {
        backgroundColor = .giniColorScheme().bottomBar.background.uiColor()

        addSubview(contentView)
        addSubview(dividerView)
        addSubview(backButton.buttonView)
        addSubview(helpButton.buttonView)
        addSubview(proceedButton)
        contentView.addSubview(totalAmountStackView)
        contentView.addSubview(skontoBadgeView)
        contentView.addSubview(savingsAmountLabel)
    }

    private func setupConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0

        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier),
            contentView.topAnchor.constraint(equalTo: topAnchor),

            dividerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight),

            totalAmountStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            totalAmountStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            totalAmountStackView.trailingAnchor.constraint(lessThanOrEqualTo: skontoBadgeView.leadingAnchor,
                                                           constant: -Constants.badgeHorizontalPadding),

            savingsAmountLabel.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor,
                                                  constant: Constants.savingsAmountLabelTopPadding),
            savingsAmountLabel.leadingAnchor.constraint(equalTo: totalValueLabel.leadingAnchor),
            savingsAmountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                         constant: -Constants.padding),
            savingsAmountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            skontoBadgeView.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            skontoBadgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Constants.padding),

            skontoBadgeLabel.topAnchor.constraint(equalTo: skontoBadgeView.topAnchor,
                                                  constant: Constants.badgeVerticalPadding),
            skontoBadgeLabel.bottomAnchor.constraint(equalTo: skontoBadgeView.bottomAnchor,
                                                     constant: -Constants.badgeVerticalPadding),
            skontoBadgeLabel.leadingAnchor.constraint(equalTo: skontoBadgeView.leadingAnchor,
                                                      constant: Constants.badgeHorizontalPadding),
            skontoBadgeLabel.trailingAnchor.constraint(equalTo: skontoBadgeView.trailingAnchor,
                                                       constant: -Constants.badgeHorizontalPadding),

            backButton.buttonView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                           constant: Constants.padding),
            backButton.buttonView.centerYAnchor.constraint(equalTo: proceedButton.centerYAnchor),

            helpButton.buttonView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                           constant: -Constants.padding),
            helpButton.buttonView.centerYAnchor.constraint(equalTo: proceedButton.centerYAnchor),

            proceedButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,
                                               constant: Constants.proceedButtonTopPadding),
            proceedButton.leadingAnchor.constraint(equalTo: backButton.buttonView.trailingAnchor),
            proceedButton.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor,
                                                 constant: -Constants.padding * 2),
            proceedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            proceedButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -Constants.verticalPadding),
            proceedButton.heightAnchor.constraint(equalToConstant: Constants.proceedButtonHeight)
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
        static let tabletWidthMultiplier: CGFloat = 0.7
        static let helpButtonHorizontalPadding: CGFloat = 25
    }
}
