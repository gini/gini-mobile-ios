//
//  SkontoProceedContainerView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class SkontoProceedContainerView: UIView {

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
        let buttonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.proceedbutton.title",
                                                                   comment: "Continue to pay")
        button.accessibilityValue = buttonTitle
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(proceedButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var totalStringLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = configuration.textStyleFonts[.subheadline]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        let labelText = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.title",
                                                                  comment: "Total")
        label.text = labelText
        label.accessibilityValue = labelText
        return label
    }()

    private lazy var finalAmountToPayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.title2Bold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        let labelText = viewModel.finalAmountToPay.localizedStringWithCurrencyCode
        label.text = labelText
        label.accessibilityValue = labelText
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var skontoPercentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().chips.textSuggestionEnabled.uiColor()
        let labelText = String.localizedStringWithFormat(skontoTitle,
                                                         viewModel.formattedPercentageDiscounted)
        label.text = labelText
        label.accessibilityValue = labelText
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var skontoBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().chips.suggestionEnabled.uiColor()
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skontoPercentageLabel)
        return view
    }()

    private lazy var savingsAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().chips.suggestionEnabled.uiColor()
        let labelText = viewModel.savingsAmountString
        label.text = labelText
        label.accessibilityValue = labelText
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var dividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = .giniColorScheme().bg.divider.uiColor()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        return dividerView
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    private let skontoTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.skontopercentage",
                                                                      comment: "%@ Skonto discount")

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .giniColorScheme().bg.surface.uiColor()
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)
        addSubview(dividerView)
        contentView.addSubview(totalStringLabel)
        contentView.addSubview(finalAmountToPayLabel)
        contentView.addSubview(skontoBadgeView)
        contentView.addSubview(savingsAmountLabel)
        contentView.addSubview(proceedButton)

        setupConstraints()
        bindViewModel()
    }

    private func setupConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0

        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dividerView.topAnchor.constraint(equalTo: topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight),

            totalStringLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            totalStringLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: Constants.padding),
            totalStringLabel.trailingAnchor.constraint(lessThanOrEqualTo: skontoBadgeView.leadingAnchor,
                                                       constant: -Constants.badgeHorizontalPadding),

            finalAmountToPayLabel.topAnchor.constraint(equalTo: totalStringLabel.bottomAnchor,
                                                       constant: Constants.totalValueLabelTopPadding),
            finalAmountToPayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                           constant: Constants.padding),
            finalAmountToPayLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                            constant: -Constants.padding),

            savingsAmountLabel.topAnchor.constraint(equalTo: finalAmountToPayLabel.bottomAnchor,
                                                    constant: Constants.savingsAmountLabelTopPadding),
            savingsAmountLabel.leadingAnchor.constraint(equalTo: finalAmountToPayLabel.leadingAnchor),
            savingsAmountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                         constant: -Constants.padding),

            skontoBadgeView.centerYAnchor.constraint(equalTo: totalStringLabel.centerYAnchor),
            skontoBadgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Constants.padding),

            skontoPercentageLabel.topAnchor.constraint(equalTo: skontoBadgeView.topAnchor,
                                                       constant: Constants.badgeVerticalPadding),
            skontoPercentageLabel.bottomAnchor.constraint(equalTo: skontoBadgeView.bottomAnchor,
                                                          constant: -Constants.badgeVerticalPadding),
            skontoPercentageLabel.leadingAnchor.constraint(equalTo: skontoBadgeView.leadingAnchor,
                                                           constant: Constants.badgeHorizontalPadding),
            skontoPercentageLabel.trailingAnchor.constraint(equalTo: skontoBadgeView.trailingAnchor,
                                                            constant: -Constants.badgeHorizontalPadding),

            proceedButton.topAnchor.constraint(equalTo: savingsAmountLabel.bottomAnchor,
                                               constant: Constants.verticalPadding),
            proceedButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -Constants.verticalPadding),
            proceedButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            proceedButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Constants.padding),
            proceedButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.proceedButtonHeight)
        ])
    }

    private func bindViewModel() {
        configure()
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure()
        }
    }

    private func configure() {
        let isSkontoApplied = viewModel.isSkontoApplied
        skontoBadgeView.isHidden = !isSkontoApplied
        skontoPercentageLabel.text = String.localizedStringWithFormat(skontoTitle,
                                                                      viewModel.formattedPercentageDiscounted)
        finalAmountToPayLabel.text = viewModel.finalAmountToPay.localizedStringWithCurrencyCode

        savingsAmountLabel.isHidden = !isSkontoApplied
        savingsAmountLabel.text = viewModel.savingsAmountString
    }

    @objc private func proceedButtonTapped() {
        viewModel.proceedButtonTapped()
    }
}

private extension SkontoProceedContainerView {
    enum Constants {
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
    }
}
