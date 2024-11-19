//
//  SkontoWithoutDiscountView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoWithoutDiscountView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withoutdiscount.title",
                                                             comment: "Without Skonto discount")
        label.text = title
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.font = configuration.textStyleFonts[.bodyBold]
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
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

    private lazy var priceView: SkontoWithoutDiscountPriceView = {
        return SkontoWithoutDiscountPriceView(viewModel: viewModel)
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
        addSubview(priceView)
        setupConstraints()
        bindViewModel()
        adjustStackViewLayout()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            priceView.topAnchor.constraint(equalTo: stackView.bottomAnchor,
                                           constant: Constants.verticalPadding),
            priceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            priceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceView.trailingAnchor.constraint(equalTo: trailingAnchor)
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
        activeLabel.isHidden = viewModel.isSkontoApplied
    }

    private func adjustStackViewLayout() {
        guard !UIDevice.current.isIpad else { return }

        let isAccessibilityCategory = UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium
        let isSmallDevice = UIScreen.main.bounds.width <= 320
        let shouldUseVerticalLayout = isAccessibilityCategory || isSmallDevice

        stackView.axis = shouldUseVerticalLayout ? .vertical : .horizontal
        stackView.alignment = shouldUseVerticalLayout ? .leading : .center
    }

    @objc private func handleContentSizeCategoryDidChange() {
        adjustStackViewLayout()
    }
}

private extension SkontoWithoutDiscountView {
    enum Constants {
        static let stackViewSpacing: CGFloat = 4
        static let verticalPadding: CGFloat = 12
    }
}
