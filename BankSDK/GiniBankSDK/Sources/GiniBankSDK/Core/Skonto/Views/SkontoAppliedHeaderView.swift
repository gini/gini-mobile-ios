//
//  SkontoAppliedHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoAppliedHeaderView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.title",
                                                              comment: "Mit Skonto")
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.font = GiniBankConfiguration.shared.textStyleFonts[.bodyBold]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(
            string: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.status",
                                                             comment: "• Aktiviert"),
            attributes: [NSAttributedString.Key.font: GiniBankConfiguration.shared.textStyleFonts[.footnoteBold]!,
                         NSAttributedString.Key.foregroundColor: GiniColor(light: .GiniBank.success3,
                                                                           dark: .GiniBank.success3).uiColor()
                        ])
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let discountSwitch: UISwitch = {
        let discountSwitch = UISwitch()
        discountSwitch.isOn = true
        discountSwitch.onTintColor = GiniColor(light: .GiniBank.accent1,
                                             dark: .GiniBank.accent1).uiColor()
        discountSwitch.translatesAutoresizingMaskIntoConstraints = false
        return discountSwitch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(discountSwitch)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),

            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),

            discountSwitch.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            discountSwitch.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            discountSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            discountSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
    }
}
