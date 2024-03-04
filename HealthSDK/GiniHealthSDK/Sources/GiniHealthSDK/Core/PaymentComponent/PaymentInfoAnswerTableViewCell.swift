//
//  PaymentInfoAnswerTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PaymentInfoAnswerTableViewCell: UITableViewCell {
    static let identifier = "PaymentInfoAnswerTableViewCell"
    
    let textView: UITextView = {
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
        self.backgroundColor = .clear
        contentView.addSubview(textView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.bottomPadding)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let cellViewModel = cellViewModel else { return }
        textView.attributedText = cellViewModel.answerAttributedText
        textView.textColor = cellViewModel.answerTextColor
    }
}

struct PaymentInfoAnswerTableViewModel {
    let answerAttributedText: NSAttributedString
    let answerTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                             darkModeColor: UIColor.GiniHealthColors.light1).uiColor()

    init(answerAttributedText: NSAttributedString) {
        self.answerAttributedText = answerAttributedText
    }
}

extension PaymentInfoAnswerTableViewCell {
    private enum Constants {
        static let bottomPadding = 16.0
    }
}
