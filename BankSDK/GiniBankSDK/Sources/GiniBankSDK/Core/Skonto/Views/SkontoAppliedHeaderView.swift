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
        label.textColor = .giniColorScheme().text.primary.uiColor()
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
                         NSAttributedString.Key.foregroundColor: UIColor.giniColorScheme().text.status.uiColor()
                        ])
        label.attributedText = attributedString
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var discountSwitch: UISwitch = {
        let discountSwitch = UISwitch()
        discountSwitch.isOn = true
        discountSwitch.onTintColor = UIColor.giniColorScheme().toggles.surfaceFocused.uiColor()
        discountSwitch.addTarget(self, action: #selector(discountSwitchToggled(_:)), for: .valueChanged)
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
        backgroundColor = .giniColorScheme().bg.surface.uiColor()
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
        configure(isSkontoApplied: viewModel.isSkontoApplied)
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure(isSkontoApplied: viewModel.isSkontoApplied)
        }
    }

    private func configure(isSkontoApplied: Bool) {
        discountSwitch.isOn = isSkontoApplied
        statusLabel.isHidden = isSkontoApplied ? false : true
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
