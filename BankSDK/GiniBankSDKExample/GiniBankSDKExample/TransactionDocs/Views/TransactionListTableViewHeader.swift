//
//  TransactionListTableViewHeader.swift
//  
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class TransactionListTableViewHeader: UITableViewCell, CodeLoadableView {
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        titleLabel.text = Constants.titleText
        titleLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        return titleLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: Constants.titleLabelVerticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: Constants.titleLabelLeadingPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                 constant: -Constants.titleLabelTrailingPadding),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                               constant: -Constants.titleLabelVerticalPadding)
        ])
    }
}

// MARK: - Constants
private extension TransactionListTableViewHeader {
    enum Constants {
        static let titleFontSize: CGFloat = 22
        static let titleText: String = "Fotozahlungsverlauf"
        static let titleLabelVerticalPadding: CGFloat = 8
        static let titleLabelLeadingPadding: CGFloat = 16
        static let titleLabelTrailingPadding: CGFloat = 8
    }
}

