//
//  SkontoHelpHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoHelpHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.header.title",
                                                                   comment: "Save money by paying promptly")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .giniColorScheme().text.primary.uiColor()
        titleLabel.font = configuration.textStyleFonts[.bodyBold]
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        return titleLabel
    }()

    private lazy var subtitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.header.subtitle",
                                                                   comment: "Many companies offer cash discounts...")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .giniColorScheme().text.secondary.uiColor()
        titleLabel.font = configuration.textStyleFonts[.body]
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        return titleLabel
    }()

    private let configuration = GiniBankConfiguration.shared

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                               constant: Constants.verticalPadding),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private extension SkontoHelpHeaderView {
    enum Constants {
        static let verticalPadding: CGFloat = 12
    }
}
