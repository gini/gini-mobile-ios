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
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.font = configuration.textStyleFonts[.bodyBold]
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var activeLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.active",
                                                             comment: "• Active")
        label.text = title
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = UIColor.giniColorScheme().text.success.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var discountSwitch: UISwitch = {
        let discountSwitch = UISwitch()
        discountSwitch.isOn = viewModel.isSkontoApplied
        discountSwitch.onTintColor = .giniColorScheme().toggle.trackOn.uiColor()
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleContentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIContentSizeCategory.didChangeNotification,
                                                  object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().container.background.uiColor()
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
            discountSwitch.leadingAnchor.constraint(equalTo: stackView.trailingAnchor,
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
        discountSwitch.isHidden = !viewModel.isWithDiscountSwitchAvailable
        activeLabel.isHidden = !isSkontoApplied
    }

    private func adjustStackViewLayout() {
        guard !UIDevice.current.isIpad else { return }

        let isAccessibilityCategory = UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium
        let isSmallDevice = UIScreen.main.bounds.width <= 320
        let shouldUseVerticalLayout = isAccessibilityCategory || isSmallDevice

        stackView.axis = shouldUseVerticalLayout ? .vertical : .horizontal
        stackView.alignment = shouldUseVerticalLayout ? .leading : .center
    }

    @objc private func discountSwitchToggled(_ sender: UISwitch) {
        viewModel.toggleDiscount()
        adjustStackViewLayout()
    }

    @objc private func handleContentSizeCategoryDidChange() {
        adjustStackViewLayout()
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
