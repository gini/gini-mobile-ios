//
//  TransactionCell.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit
import GiniBankSDK
import GiniCaptureSDK

class TransactionCell: UITableViewCell, CodeLoadableView {
    private let paymentRecipientInitialsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4).uiColor()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        return label
    }()
    private let paymentRecipientLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    private let paymentDetailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()

    private let paymentPurposeLabel = UILabel()
    private let paymentReferenceLabel = UILabel()
    private let attachmentsStackView = UIStackView()
    private let attachmentsContainerView = UIView()

    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor()
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let bgColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        backgroundColor = .clear
        contentView.backgroundColor = bgColor
        selectionStyle = .none

        // Configure labels and stackView
        amountLabel.font = UIFont.systemFont(ofSize: 17)
        amountLabel.textAlignment = .right

        paymentRecipientLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        paymentRecipientLabel.font = UIFont.systemFont(ofSize: 17)

        paymentPurposeLabel.font = UIFont.systemFont(ofSize: 13)
        paymentPurposeLabel.textColor = GiniColor(light: .GiniBank.light6, dark: .GiniBank.dark7).uiColor()

        paymentReferenceLabel.font = UIFont.systemFont(ofSize: 13)
        paymentReferenceLabel.textColor = GiniColor(light: .GiniBank.light6, dark: .GiniBank.dark7).uiColor()

        dateLabel.textColor = GiniColor(light: .GiniBank.light6, dark: .GiniBank.dark7).uiColor()
        dateLabel.font = UIFont.systemFont(ofSize: 13)

        attachmentsStackView.axis = .horizontal
        attachmentsStackView.spacing = 4
        attachmentsStackView.distribution = .equalSpacing

        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 8
        horizontalStackView.distribution = .fill

        horizontalStackView.addArrangedSubview(paymentRecipientInitialsLabel)

        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4
        verticalStackView.addArrangedSubview(paymentRecipientLabel)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(paymentPurposeLabel)
        verticalStackView.addArrangedSubview(paymentReferenceLabel)

        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(amountLabel)
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        attachmentsContainerView.addSubview(attachmentsStackView)
        attachmentsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            attachmentsStackView.topAnchor.constraint(equalTo: attachmentsContainerView.topAnchor,
                                                      constant: Constants.attachmentsStackViewVerticalPedding),
            attachmentsStackView.leadingAnchor.constraint(equalTo: attachmentsContainerView.leadingAnchor,
                                                          constant: Constants.attachmentsStackViewLeftPedding),
            attachmentsStackView.bottomAnchor.constraint(equalTo: attachmentsContainerView.bottomAnchor,
                                                         constant: -Constants.attachmentsStackViewVerticalPedding)
        ])

        let mainStackView = UIStackView(arrangedSubviews: [horizontalStackView, attachmentsContainerView, dividerView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 8

        addSubview(mainStackView)

        paymentRecipientInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        let size = Constants.paymentRecipientInitialsLabelSize
        paymentRecipientInitialsLabel.widthAnchor.constraint(equalToConstant: size).isActive = true
        paymentRecipientInitialsLabel.heightAnchor.constraint(equalToConstant: size).isActive = true

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight).isActive = true

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.mainHorizontalSpacing),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.mainVerticalSpacing),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.mainVerticalSpacing),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.mainHorizontalSpacing)
        ])
    }

    func configure(with transaction: Transaction, isLastCell: Bool = false) {
        paymentRecipientInitialsLabel.text = transaction.paymentRecipient.acronym()
        paymentRecipientLabel.text = transaction.paymentRecipient
        amountLabel.text = "-" + transaction.paiedAmount
        dateLabel.text = transaction.date.toFormattedString()
        paymentPurposeLabel.text = transaction.paymentPurpose
        paymentReferenceLabel.text = transaction.paymentReference
        dividerView.isHidden = isLastCell

        attachmentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        attachmentsStackView.isHidden = transaction.attachments.isEmpty
        attachmentsContainerView.isHidden = transaction.attachments.isEmpty
        for attachment in transaction.attachments {
            let view = AttachmentView(data: attachment)
            attachmentsStackView.addArrangedSubview(view)
        }
    }
}
// MARK: - Constants
private extension TransactionCell {
    enum Constants {
        static let mainHorizontalSpacing: CGFloat = 15
        static let mainVerticalSpacing: CGFloat = 12
        static let paymentRecipientInitialsLabelSize: CGFloat = 40
        static let dividerViewHeight: CGFloat = 1
        static let attachmentsStackViewLeftPedding: CGFloat = 40
        static let attachmentsStackViewVerticalPedding: CGFloat = 8
    }
}
