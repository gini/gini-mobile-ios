//
//  SkontoHelpItemView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

final class SkontoHelpItemView: UIView {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .none
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .giniColorScheme().text.primary.uiColor()
        titleLabel.font = configuration.textStyleFonts[.bodyBold]
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        return titleLabel
    }()

    private let configuration = GiniBankConfiguration.shared

    init(content: SkontoHelpItem, separator: Bool) {
        super.init(frame: .zero)
        setupView(with: content, separator: separator)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(with content: SkontoHelpItem, separator: Bool) {
        backgroundColor = .clear
        iconImageView.image = content.icon
        iconImageView.accessibilityValue = content.title
        titleLabel.text = content.title
        titleLabel.accessibilityValue = content.title

        addSubview(iconImageView)
        addSubview(titleLabel)
        if separator {
            addSeparatorView()
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                               constant: Constants.verticalPadding),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                   constant: Constants.horizontalPadding),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize.height),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize.width),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                                  constant: -Constants.verticalPadding),

            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                            constant: Constants.verticalPadding),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                               constant: -Constants.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor,
                                                constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -Constants.horizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])
    }

    private func addSeparatorView() {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .giniColorScheme().bg.divider.uiColor()
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorViewHeight),
            separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -Constants.horizontalPadding)
        ])
    }
}

private extension SkontoHelpItemView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 10
        static let iconSize = CGSize(width: 48, height: 48)
        static let separatorViewHeight: CGFloat = 1
        static let separatorLeadingPadding: CGFloat = 80
        static let separatorTrailingPadding: CGFloat = 16
    }
}
