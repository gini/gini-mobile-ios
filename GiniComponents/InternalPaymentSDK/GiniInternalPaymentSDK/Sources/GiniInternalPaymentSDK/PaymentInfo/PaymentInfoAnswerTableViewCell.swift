//
//  PaymentInfoAnswerTableViewCell.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

final class PaymentInfoAnswerTableViewCell: UITableViewCell, ReusableView {
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        return textView
    }()
    
    var cellViewModel: PaymentInfoAnswerTableViewModel? {
        didSet {
            configure()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.addSubview(textView)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.bottomPadding)
        ])
    }

    private func configure() {
        guard let cellViewModel = cellViewModel else { return }
        textView.attributedText = cellViewModel.answerAttributedText
        textView.textColor = cellViewModel.answerTextColor
        textView.linkTextAttributes = cellViewModel.answerLinkAttributes
        textView.layoutIfNeeded()
    }
}

struct PaymentInfoAnswerTableViewModel {
    let answerAttributedText: NSAttributedString
    let answerTextColor: UIColor
    let answerLinkAttributes: [NSAttributedString.Key: Any]

    init(answerAttributedText: NSAttributedString, answerTextColor: UIColor, answerLinkColor: UIColor) {
        self.answerAttributedText = answerAttributedText
        self.answerTextColor = answerTextColor
        self.answerLinkAttributes = [.foregroundColor: answerLinkColor]
    }
}

extension PaymentInfoAnswerTableViewCell {
    private enum Constants {
        static let bottomPadding = 16.0
    }
}
