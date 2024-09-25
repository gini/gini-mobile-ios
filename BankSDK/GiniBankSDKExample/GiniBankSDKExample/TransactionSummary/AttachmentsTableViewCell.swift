//
//  AttachmentsTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankSDK
import GiniCaptureSDK

class AttachmentsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AttachmentsTableViewCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = Constants.containerViewBorderColor.cgColor
        view.layer.borderWidth = Constants.containerViewBorderWidth
        view.layer.cornerRadius = Constants.containerViewBorderCornerRadius
        view.backgroundColor = GiniColor(light: .GiniBank.light1,
                                         dark: .GiniBank.dark3).uiColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        addSubview(containerView)
        containerView.addSubview(attachmentsView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                   constant: Constants.padding),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                    constant: -Constants.padding),
            containerView.topAnchor.constraint(equalTo: topAnchor,
                                               constant: Constants.padding),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                  constant: -Constants.padding),

            attachmentsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                     constant: Constants.containerPadding),
            attachmentsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                      constant: -Constants.containerPadding),
            attachmentsView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                                 constant: Constants.containerPadding),
            attachmentsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                    constant: -Constants.containerPadding)
        ])
    }

    func configure(delegate: TransactionDocsViewDelegate?) {
        attachmentsView.delegate = delegate
    }
}

private extension AttachmentsTableViewCell {
    enum Constants {
        static let padding: CGFloat = 16
        static let containerViewBorderColor: UIColor = GiniColor(light: .GiniBank.light3,
                                                                 dark: .GiniBank.dark4).uiColor()
        static let containerViewBorderWidth: CGFloat = 1.0
        static let containerViewBorderCornerRadius: CGFloat = 8.0
        static let containerPadding: CGFloat = 12
    }
}
