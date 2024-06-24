//
//  SkontoAppliedHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoAppliedHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.title",
                                                              comment: "Mit Skonto")
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.font = configuration.textStyleFonts[.bodyBold]
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(
            string: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.status",
                                                             comment: "• Aktiviert"),
            attributes: [NSAttributedString.Key.font: configuration.textStyleFonts[.footnoteBold]!,
                         NSAttributedString.Key.foregroundColor: GiniColor(light: .GiniBank.success3,
                                                                           dark: .GiniBank.success3).uiColor()
                        ])
        label.attributedText = attributedString
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var discountSwitch: UISwitch = {
        let discountSwitch = UISwitch()
        discountSwitch.isOn = true
        discountSwitch.onTintColor = GiniColor(light: .GiniBank.accent1,
                                             dark: .GiniBank.accent1).uiColor()
        discountSwitch.translatesAutoresizingMaskIntoConstraints = false
        return discountSwitch
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    public init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(discountSwitch)
        setupConstraints()
        bindViewModel()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constants.statusLabelHorizontalPadding),

            discountSwitch.topAnchor.constraint(equalTo: topAnchor, constant: Constants.discountSwitchTopPadding),
            discountSwitch.bottomAnchor.constraint(equalTo: bottomAnchor),
            discountSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            discountSwitch.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        discountSwitch.isOn = viewModel.isSkontoApplied
        discountSwitch.addTarget(self, action: #selector(discountSwitchToggled(_:)), for: .valueChanged)
        viewModel.onSkontoToggle = { [weak self] isSkontoApplied in
            guard let self else { return }
            self.discountSwitch.isOn = isSkontoApplied
        }
    }

    @objc private func discountSwitchToggled(_ sender: UISwitch) {
        viewModel.toggleDiscount()
    }
}

private extension SkontoAppliedHeaderView {
    enum Constants {
        static let statusLabelHorizontalPadding: CGFloat = 4
        static let discountSwitchTopPadding: CGFloat = 12
    }
}
