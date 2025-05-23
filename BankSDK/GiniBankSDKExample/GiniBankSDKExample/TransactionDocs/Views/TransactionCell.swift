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
        label.backgroundColor = Constants.recipientInitialsBackgroundColor
        label.font = Constants.boldFont
        label.textColor = Constants.primaryTextColor
        label.layer.cornerRadius = Constants.recipientInitialsCornerRadius
        label.clipsToBounds = true
        return label
    }()
    private let paymentRecipientLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    private let paymentDetailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.paymentDetailStackViewSpacing
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
        amountLabel.font = Constants.amountLabelFont
        amountLabel.textAlignment = .right

        paymentRecipientLabel.textColor = Constants.primaryTextColor
        paymentRecipientLabel.font = Constants.primaryFont

        paymentPurposeLabel.font = Constants.secondaryFont
        paymentPurposeLabel.textColor = Constants.secondaryTextColor

        paymentReferenceLabel.font = Constants.secondaryFont
        paymentReferenceLabel.textColor = Constants.secondaryTextColor

        dateLabel.textColor = Constants.secondaryTextColor
        dateLabel.font = Constants.secondaryFont

        attachmentsStackView.axis = .horizontal
        attachmentsStackView.spacing = Constants.attachmentsStackViewSpacing
        attachmentsStackView.distribution = .equalSpacing

        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = Constants.horizontalStackViewSpacing
        horizontalStackView.distribution = .fill

        horizontalStackView.addArrangedSubview(paymentRecipientInitialsLabel)

        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = Constants.verticalStackViewSpacing
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
        mainStackView.spacing = Constants.mainStackViewSpacing

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
        amountLabel.text = "-" + transaction.paidAmount
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
        static let amountLabelFont: UIFont = UIFont.systemFont(ofSize: 17)
        static let primaryFont: UIFont = UIFont.systemFont(ofSize: 17)
        static let secondaryFont: UIFont = UIFont.systemFont(ofSize: 13)
        static let boldFont: UIFont = .boldSystemFont(ofSize: 16)
        static let primaryTextColor: UIColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        static let secondaryTextColor: UIColor = GiniColor(light: .GiniBank.light6, dark: .GiniBank.light6).uiColor()
        static let recipientInitialsBackgroundColor: UIColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4).uiColor()

        // StackView Spacing
        static let paymentDetailStackViewSpacing: CGFloat = 2
        static let attachmentsStackViewSpacing: CGFloat = 4
        static let horizontalStackViewSpacing: CGFloat = 8
        static let verticalStackViewSpacing: CGFloat = 4
        static let mainStackViewSpacing: CGFloat = 8

        static let recipientInitialsCornerRadius: CGFloat = 20
    }
}
