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
        let buttonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.paybutton.title",
                                                                   comment: "Proceed")
        button.accessibilityValue = buttonTitle
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(proceedButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = configuration.textStyleFonts[.body]
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
        label.font = configuration.textStyleFonts[.title1Bold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        let labelText = viewModel.totalPrice.localizedStringWithCurrencyCode
        label.text = labelText
        label.accessibilityValue = labelText
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var skontoBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.caption1]
        label.textColor = .giniColorScheme().chips.textSuggestionEnabled.uiColor()
        let labelText = String.localizedStringWithFormat(skontoTitle,
                                                         viewModel.skontoFormattedPercentageDiscounted)
        label.text = labelText
        label.accessibilityValue = labelText
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

    private lazy var dividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = .giniColorScheme().bg.divider.uiColor()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        return dividerView
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    private let skontoTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.amount.skonto",
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

            totalValueLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor),
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

            proceedButton.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: Constants.verticalPadding),
            // TODO: no safe area bottom padding in design
            proceedButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                              constant: -Constants.verticalPadding),
            proceedButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            proceedButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            proceedButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonHeight)
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
        self.skontoBadgeView.isHidden = !isSkontoApplied
        self.skontoBadgeLabel.text = String.localizedStringWithFormat(skontoTitle,
                                                                      viewModel.skontoFormattedPercentageDiscounted)
        self.totalValueLabel.text = viewModel.totalPrice.localizedStringWithCurrencyCode
    }

    @objc private func proceedButtonTapped() {
        self.viewModel.proceedButtonTapped()
    }
}

private extension SkontoProceedView {
    enum Constants {
        static let padding: CGFloat = 24
        static let verticalPadding: CGFloat = 16
        static let buttonHeight: CGFloat = 50
        static let dividerViewHeight: CGFloat = 1
        static let badgeHorizontalPadding: CGFloat = 6
        static let badgeVerticalPadding: CGFloat = 2
        static let badgeSpacing: CGFloat = 12
    }
}
