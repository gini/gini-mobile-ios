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
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(proceedButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var totalStringLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.subheadline]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        let labelText = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.title",
                                                                  comment: "Total")
        label.text = labelText
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.enableScaling(minimumScaleFactor: 15)
        return label
    }()

    private lazy var finalAmountToPayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.title2Bold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        let labelText = viewModel.finalAmountToPay.localizedStringWithCurrencyCode
        label.text = labelText
        label.numberOfLines = 1
        label.enableScaling(minimumScaleFactor: 15)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var totalAmountStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalStringLabel, finalAmountToPayLabel])
        stackView.axis = .vertical
        stackView.spacing = Constants.totalValueLabelTopPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isAccessibilityElement = true
        stackView.accessibilityLabel = "\(totalStringLabel.text ?? "") \(finalAmountToPayLabel.text ?? "")"
        return stackView
    }()

    private lazy var skontoPercentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().badge.content.uiColor()
        let labelText = String.localizedStringWithFormat(skontoTitle,
                                                         viewModel.formattedPercentageDiscounted)
        label.text = labelText
        label.numberOfLines = 1
        label.enableScaling()
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
        view.addSubview(skontoPercentageLabel)
        return view
    }()

    private lazy var savingsAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().badge.background.uiColor()
        let labelText = viewModel.savingsAmountString
        label.text = labelText
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

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    private let skontoTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.skontopercentage",
                                                                      comment: "%@ Skonto discount")

    private var skontoBadgeCompactLeadingConstraint: NSLayoutConstraint?
    private var totalAmountStackViewDefultLeadingConstraint: NSLayoutConstraint?
    private var skontoBadgeMinWidthConstraint: NSLayoutConstraint?

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .giniColorScheme().bottomBar.background.uiColor()
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)
        addSubview(dividerView)
        contentView.addSubview(totalAmountStackView)
        contentView.addSubview(skontoBadgeView)
        contentView.addSubview(savingsAmountLabel)
        contentView.addSubview(proceedButton)

        setupConstraints()
        bindViewModel()
        adjustLayoutForAccessibility()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adjustLayoutForAccessibility()
    }

    private func setupConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0
        let contentViewTrailingAnchor = contentView.safeAreaLayoutGuide.trailingAnchor

        let skontoCompactLeadinConstraint = Constants.skontoBadgeCompactLeadingConstraint
        skontoBadgeCompactLeadingConstraint = skontoBadgeView.leadingAnchor
            .constraint(equalTo: totalStringLabel.trailingAnchor,
                        constant: skontoCompactLeadinConstraint)

        totalAmountStackViewDefultLeadingConstraint = totalAmountStackView.trailingAnchor
            .constraint(lessThanOrEqualTo: skontoBadgeView.leadingAnchor,
                        constant: -Constants.badgeHorizontalPadding)

        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dividerView.topAnchor.constraint(equalTo: topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight),

            totalAmountStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            totalAmountStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                                                          constant: Constants.padding),

            savingsAmountLabel.topAnchor.constraint(equalTo: finalAmountToPayLabel.bottomAnchor,
                                                    constant: Constants.savingsAmountLabelTopPadding),
            savingsAmountLabel.leadingAnchor.constraint(equalTo: finalAmountToPayLabel.leadingAnchor),
            savingsAmountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentViewTrailingAnchor,
                                                         constant: -Constants.padding),

            skontoBadgeView.centerYAnchor.constraint(equalTo: totalStringLabel.centerYAnchor),
            skontoBadgeView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
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
            proceedButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: Constants.padding),
            proceedButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.proceedButtonHeight)
        ])
    }

    private func adjustLayoutForAccessibility() {
        guard UIDevice.current.isIphone else { return }

        let isAccessibilityCategory = UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium
        // Later this will be factor and use the generic methods that are inside UIDevice extension
        let isSmallDevice = UIDevice.current.userInterfaceIdiom == .phone &&
            UIScreen.main.bounds.size.width <= 375 // iPhone SE and smaller
        let shouldUseCompactLayout = isAccessibilityCategory && isSmallDevice

        let horizontalPriority: UILayoutPriority = isAccessibilityCategory ? .defaultHigh : .defaultLow
        skontoPercentageLabel.setContentHuggingPriority(horizontalPriority,
                                                        for: .horizontal)
        skontoPercentageLabel.setContentCompressionResistancePriority(horizontalPriority,
                                                                      for: .horizontal)

        if shouldUseCompactLayout {
            let skontoBadgeWidth = Constants.skontoBadgeMinWidthCompactLayout
            skontoBadgeMinWidthConstraint = skontoBadgeView.widthAnchor
                .constraint(greaterThanOrEqualToConstant: skontoBadgeWidth)
            skontoBadgeMinWidthConstraint?.isActive = true
            skontoBadgeCompactLeadingConstraint?.isActive = true
            totalAmountStackViewDefultLeadingConstraint?.isActive = false

        } else {
            skontoBadgeMinWidthConstraint?.isActive = false
            skontoBadgeCompactLeadingConstraint?.isActive = false
            totalAmountStackViewDefultLeadingConstraint?.isActive = true
        }

        layoutIfNeeded()
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
        static let skontoBadgeTopPadding: CGFloat = 8
        static let skontoBadgeMinWidthCompactLayout: CGFloat = 100
        static let skontoBadgeCompactLeadingConstraint: CGFloat = 8
    }
}
