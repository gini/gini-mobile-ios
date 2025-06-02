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

    lazy var navigationBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().bottomBar.background.uiColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var contentBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().bottomBar.background.uiColor()
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
        button.titleTextAlignment = .right
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

    private lazy var navigationBarDividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = .giniColorScheme().bottomBar.border.uiColor()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        return dividerView
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
        updatePhoneLayoutForCurrentOrientation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIDevice.current.isIphone else { return }
        updatePhoneLayoutForCurrentOrientation()
    }

    private func updatePhoneLayoutForCurrentOrientation() {
        let isLandscape = UIDevice.current.isLandscape

        subviews.forEach { $0.removeFromSuperview() }

        if isLandscape && configuration.bottomNavigationBarEnabled {
            setupLandscapeView()
            setupLandscapeConstraints()
        } else {
            setupPortraitView()
            setupPortraitConstraints()
        }
    }

    private func setupPortraitView() {
        backgroundColor = .giniColorScheme().bottomBar.background.uiColor()

        addSubview(dividerView)
        addSubview(contentView)
        addSubview(backButton.buttonView)
        addSubview(helpButton.buttonView)
        addSubview(proceedButton)
        contentView.addSubview(totalAmountStackView)
        contentView.addSubview(skontoBadgeView)
        contentView.addSubview(savingsAmountLabel)
    }

    private func setupPortraitConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0

        setupContentViewConstraints(multiplier: multiplier, in: self)
        setupDividerViewConstraints(in: self)
        setupTotalAmountSectionConstraints()
        setupSkontoBadgeConstraints()
        setupSavingsAmountConstraints()
        setupProceedButtonConstraints(in: self,
                                      bottomTo: safeAreaLayoutGuide.bottomAnchor)

        setupNavigationButtonConstraints(in: self,
                                         alignVerticallyTo: proceedButton.centerYAnchor,
                                         horizontalPadding: Constants.padding)
    }

    private func setupLandscapeView() {
        backgroundColor = .giniColorScheme().bottomBar.background.uiColor()

        addSubview(navigationBarView)

        // Add children to navigation bar
        navigationBarView.addSubview(navigationBarDividerView)
        navigationBarView.addSubview(backButton.buttonView)
        navigationBarView.addSubview(helpButton.buttonView)

        // views related to Skonto payment and summary
        addSubview(contentBarView)
        // Add children to content bar
        contentBarView.addSubview(dividerView)
        contentBarView.addSubview(contentView)
        contentBarView.addSubview(proceedButton)

        contentView.addSubview(totalAmountStackView)
        contentView.addSubview(skontoBadgeView)
        contentView.addSubview(savingsAmountLabel)
    }

    private func setupLandscapeConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0

        setupNavigationDividerConstraints()
        setupNavigationBarContainerConstraints()
        setupNavigationButtonConstraints(in: navigationBarView,
                                         alignVerticallyTo: navigationBarView.centerYAnchor,
                                         horizontalPadding: Constants.landscapePadding)

        // contraints for views related to Skonto payment and summary
        setupContentBarContainerConstraints()
        setupContentViewConstraints(multiplier: multiplier, in: contentBarView)
        setupDividerViewConstraints(in: contentBarView)
        setupTotalAmountSectionConstraints()
        setupSkontoBadgeConstraints()
        setupSavingsAmountConstraints()
        setupProceedButtonConstraints(in: contentBarView,
                                      bottomTo: contentBarView.bottomAnchor,
                                      fullWidth: true)
    }

    private func setupNavigationDividerConstraints() {
        NSLayoutConstraint.activate([
            navigationBarDividerView.topAnchor.constraint(equalTo: navigationBarView.topAnchor),
            navigationBarDividerView.leadingAnchor.constraint(equalTo: navigationBarView.leadingAnchor),
            navigationBarDividerView.trailingAnchor.constraint(equalTo: navigationBarView.trailingAnchor),
            navigationBarDividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight)
        ])
    }

    private func setupNavigationBarContainerConstraints() {
        NSLayoutConstraint.activate([
            navigationBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBarView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            navigationBarView.heightAnchor.constraint(equalToConstant: Constants.navigationBarViewDefaultHeight)
        ])
    }

    private func setupNavigationButtonConstraints(in parent: UIView,
                                                  alignVerticallyTo verticalAnchor: NSLayoutYAxisAnchor,
                                                  horizontalPadding: CGFloat) {
        NSLayoutConstraint.activate([
            backButton.buttonView.leadingAnchor.constraint(equalTo: parent.leadingAnchor,
                                                           constant: horizontalPadding),
            backButton.buttonView.centerYAnchor.constraint(equalTo: verticalAnchor),

            helpButton.buttonView.trailingAnchor.constraint(equalTo: parent.trailingAnchor,
                                                            constant: -horizontalPadding),
            helpButton.buttonView.centerYAnchor.constraint(equalTo: verticalAnchor)
        ])
    }

    private func setupContentBarContainerConstraints() {
        NSLayoutConstraint.activate([
            contentBarView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                    constant: Constants.landscapePadding),
            contentBarView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                     constant: -Constants.landscapePadding),
            contentBarView.topAnchor.constraint(equalTo: topAnchor),
            contentBarView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupContentViewConstraints(multiplier: CGFloat, in parent: UIView) {
        let padding = UIDevice.current.orientation.isLandscape ? Constants.landscapePadding : Constants.padding

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: padding),
            contentView.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -padding),
            contentView.topAnchor.constraint(equalTo: parent.topAnchor)
        ])
    }

    private func setupDividerViewConstraints(in parent: UIView) {
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: parent.topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight)
        ])
    }

    private func setupTotalAmountSectionConstraints() {
        NSLayoutConstraint.activate([
            totalAmountStackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                      constant: Constants.padding),
            totalAmountStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                          constant: Constants.padding),
            totalAmountStackView.trailingAnchor.constraint(lessThanOrEqualTo: skontoBadgeView.leadingAnchor,
                                                           constant: -Constants.badgeHorizontalPadding)
        ])
    }

    private func setupSavingsAmountConstraints() {
        NSLayoutConstraint.activate([
            savingsAmountLabel.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor,
                                                    constant: Constants.savingsAmountLabelTopPadding),
            savingsAmountLabel.leadingAnchor.constraint(equalTo: totalValueLabel.leadingAnchor),
            savingsAmountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                         constant: -Constants.padding),
            savingsAmountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupSkontoBadgeConstraints() {
        NSLayoutConstraint.activate([
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
                                                       constant: -Constants.badgeHorizontalPadding)
        ])
    }

    private func setupProceedButtonConstraints(in parent: UIView,
                                               bottomTo bottomAnchor: NSLayoutYAxisAnchor,
                                               fullWidth: Bool = false) {
        var constraints: [NSLayoutConstraint] = [
            proceedButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,
                                               constant: Constants.proceedButtonTopPadding),
            proceedButton.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                  constant: -Constants.verticalPadding),
            proceedButton.heightAnchor.constraint(equalToConstant: Constants.proceedButtonHeight),
            proceedButton.centerXAnchor.constraint(equalTo: parent.centerXAnchor)
        ]

        if fullWidth {
            constraints.append(contentsOf: [
                proceedButton.leadingAnchor.constraint(equalTo: parent.leadingAnchor,
                                                       constant: Constants.landscapePadding),
                proceedButton.trailingAnchor.constraint(equalTo: parent.trailingAnchor,
                                                        constant: -Constants.landscapePadding)
            ])
        } else {
            constraints.append(contentsOf: [
                proceedButton.leadingAnchor.constraint(equalTo: backButton.buttonView.trailingAnchor),
                proceedButton.trailingAnchor.constraint(equalTo: helpButton.buttonView.leadingAnchor)
            ])
        }

        NSLayoutConstraint.activate(constraints)
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
        static let landscapePadding: CGFloat = UIDevice.current.isSmallIphone ? 16 : 56
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
        static let navigationBarViewDefaultHeight: CGFloat = 62
    }
}
