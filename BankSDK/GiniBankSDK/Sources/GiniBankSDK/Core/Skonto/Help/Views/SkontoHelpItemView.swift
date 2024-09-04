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
        titleLabel.font = configuration.textStyleFonts[.footnoteBold]
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = Constants.labelNumberOfLines
        return titleLabel
    }()

    private let configuration = GiniBankConfiguration.shared

    init(content: SkontoHelpItem, hideDivider: Bool) {
        super.init(frame: .zero)
        setupView(with: content, hideDivider: hideDivider)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(with content: SkontoHelpItem, hideDivider: Bool) {
        backgroundColor = .clear
        iconImageView.image = content.icon
        iconImageView.accessibilityValue = content.title
        titleLabel.text = content.title
        titleLabel.accessibilityValue = content.title

        addSubview(iconImageView)
        addSubview(titleLabel)
        if !hideDivider {
            addDividerView()
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

    private func addDividerView() {
        let dividerView = UIView()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .giniColorScheme().bg.divider.uiColor()
        addSubview(dividerView)
        NSLayoutConstraint.activate([
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight),
            dividerView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -Constants.horizontalPadding)
        ])
    }
}

private extension SkontoHelpItemView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 10
        static let iconSize = CGSize(width: 48, height: 48)
        static let dividerViewHeight: CGFloat = 1
        static let dividerLeadingPadding: CGFloat = 80
        static let dividerTrailingPadding: CGFloat = 16
        static let labelNumberOfLines: Int = 0
    }
}
