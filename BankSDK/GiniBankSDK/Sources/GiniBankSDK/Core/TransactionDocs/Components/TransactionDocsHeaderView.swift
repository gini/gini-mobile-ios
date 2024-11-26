//
//  TransactionDocsHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TransactionDocsHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.componentView.title",
                                                            comment: "Attachments")
        label.text = text
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.isAccessibilityElement = true
        label.accessibilityLabel = text
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
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.headerLabelBottomAnchor)
        ])
    }
}

private extension TransactionDocsHeaderView {
    enum Constants {
        static let headerLabelBottomAnchor: CGFloat = -8
    }
}
