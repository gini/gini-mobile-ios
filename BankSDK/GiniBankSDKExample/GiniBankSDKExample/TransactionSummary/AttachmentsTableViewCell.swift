//
//  AttachmentsTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankSDK

class AttachmentsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AttachmentsTableViewCell"
    
    private lazy var attachmentsView: TransactionDocsView = {
        let view = TransactionDocsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        selectionStyle = .none
        contentView.addSubview(attachmentsView)

        NSLayoutConstraint.activate([
            attachmentsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            attachmentsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            attachmentsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            attachmentsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding)
        ])
    }

    func configure(presentingViewController: UIViewController,
                   delegate: TransactionDocsViewDelegate?,
                   docs: [TransactionDoc]) {
        attachmentsView.delegate = delegate
        attachmentsView.presentingViewController = presentingViewController
        attachmentsView.transactionDocs = docs
    }
}

private extension AttachmentsTableViewCell {
    enum Constants {
        static let padding: CGFloat = 16
    }
}
