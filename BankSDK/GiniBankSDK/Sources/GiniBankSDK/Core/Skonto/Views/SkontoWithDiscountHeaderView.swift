//
//  SkontoWithDiscountHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoWithDiscountHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withdiscount.title",
                                                             comment: "With Skonto discount")
        label.text = title
        label.accessibilityValue = title
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.font = configuration.textStyleFonts[.bodyBold]
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var activeLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.active",
                                                             comment: "• Active")
        label.text = title
        label.accessibilityValue = title
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = UIColor.giniColorScheme().text.status.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var discountSwitch: UISwitch = {
        let discountSwitch = UISwitch()
        discountSwitch.isOn = viewModel.isSkontoApplied
        discountSwitch.onTintColor = .giniColorScheme().toggles.surfaceFocused.uiColor()
        discountSwitch.addTarget(self, action: #selector(discountSwitchToggled(_:)), for: .valueChanged)
        discountSwitch.translatesAutoresizingMaskIntoConstraints = false
        return discountSwitch
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, activeLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().bg.surface.uiColor()
        addSubview(stackView)
        addSubview(discountSwitch)
        setupConstraints()
        bindViewModel()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                           constant: Constants.stackViewVerticalPadding),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),

            discountSwitch.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                                constant: Constants.discountSwitchTopPadding),
            discountSwitch.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            discountSwitch.trailingAnchor.constraint(equalTo: trailingAnchor),
            discountSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor,
                                                    constant: Constants.discountSwitchLeadingPadding),
            discountSwitch.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
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
        discountSwitch.isOn = isSkontoApplied
        activeLabel.isHidden = !isSkontoApplied
    }

    @objc private func discountSwitchToggled(_ sender: UISwitch) {
        viewModel.toggleDiscount()
    }
}

private extension SkontoWithDiscountHeaderView {
    enum Constants {
        static let stackViewSpacing: CGFloat = 4
        static let stackViewVerticalPadding: CGFloat = 16
        static let discountSwitchLeadingPadding: CGFloat = 4
        static let discountSwitchTopPadding: CGFloat = 12
    }
}
