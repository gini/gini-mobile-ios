//
//  TransactionDocsHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TransactionDocsHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.invoice.transactionDoc.title",
                                                              comment: "Attachments")
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let configuration = GiniBankConfiguration.shared

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.headerLabelLeadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: Constants.headerLabelTrailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.headerLabelTopAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.headerLabelBottomAnchor)
        ])
    }
}

private extension TransactionDocsHeaderView {
    enum Constants {
        static let headerLabelLeadingAnchor: CGFloat = 12
        static let headerLabelTrailingAnchor: CGFloat = -12
        static let headerLabelTopAnchor: CGFloat = 12
        static let headerLabelBottomAnchor: CGFloat = -8
    }
}
