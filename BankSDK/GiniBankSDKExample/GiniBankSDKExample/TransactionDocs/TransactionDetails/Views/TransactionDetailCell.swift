//
//  TransactionDetailCell.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class TransactionDetailCell: UITableViewCell, CodeLoadableView {

    // MARK: - Subviews
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        // Configure the container view
        containerView.layer.cornerRadius = Constants.containerViewBorderCornerRadius
        containerView.layer.borderWidth = Constants.containerViewBorderWidth
        containerView.layer.borderColor = Constants.containerViewBorderColor.cgColor
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // Configure the title label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .gray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Configure the value label
        valueLabel.font = UIFont.preferredFont(forTextStyle: .body)
        valueLabel.textColor = .black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(valueLabel)

        // Add constraints
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Constants.containerHorizontalPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -Constants.containerHorizontalPadding),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),

            // Value label constraints
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Configuration
    func configure(with title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

private extension TransactionDetailCell {
    enum Constants {
        static let padding: CGFloat = 16
        static let containerViewBorderColor: UIColor = GiniColor(light: .GiniBank.light3,
                                                                 dark: .GiniBank.dark4).uiColor()
        static let containerViewBorderWidth: CGFloat = 1.0
        static let containerViewBorderCornerRadius: CGFloat = 8.0
        static let containerHorizontalPadding: CGFloat = 16
    }
}
