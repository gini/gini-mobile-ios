//
//  SkontoProceedView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class SkontoProceedView: UIView {
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

    private lazy var totalLabel: UILabel = {
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

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.title2Bold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        let labelText = viewModel.finalAmountToPay.localizedStringWithCurrencyCode
        label.text = labelText
        label.accessibilityValue = labelText
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var skontoBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().chips.textSuggestionEnabled.uiColor()
        let labelText = String.localizedStringWithFormat(skontoTitle,
                                                         viewModel.formattedPercentageDiscounted)
        label.text = labelText
        label.numberOfLines = 0
        label.accessibilityValue = labelText
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
        let labelText = viewModel.savingsAmountString
        label.text = labelText
        label.numberOfLines = 0
        label.accessibilityValue = labelText
        label.adjustsFontForContentSizeCategory = true
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

        addSubview(dividerView)
        addSubview(totalLabel)
        addSubview(totalValueLabel)
        addSubview(skontoBadgeView)
        addSubview(savingsAmountLabel)
        addSubview(proceedButton)

        setupConstraints()
        bindViewModel()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight),

            totalLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: Constants.padding),
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            totalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),

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

            proceedButton.topAnchor.constraint(equalTo: savingsAmountLabel.bottomAnchor,
                                               constant: Constants.verticalPadding),
            proceedButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                              constant: -Constants.verticalPadding),
            proceedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            proceedButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
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
        skontoBadgeLabel.text = String.localizedStringWithFormat(skontoTitle,
                                                                 viewModel.formattedPercentageDiscounted)
        totalValueLabel.text = viewModel.finalAmountToPay.localizedStringWithCurrencyCode

        savingsAmountLabel.isHidden = !isSkontoApplied
        savingsAmountLabel.text = viewModel.savingsAmountString
    }

    @objc private func proceedButtonTapped() {
        viewModel.proceedButtonTapped()
    }
}

private extension SkontoProceedView {
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
    }
}
