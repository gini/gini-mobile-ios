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
        return textView
    }()
    
    var cellViewModel: PaymentInfoAnswerTableViewModel? {
        didSet {
            configure()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    private var answerFont: UIFont
    let answerTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                            darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    init(answerText: String) {
        let giniConfiguration = GiniHealthConfiguration.shared
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.lineHeight
        paragraphStyle.paragraphSpacing = Constants.paragraphSpacing
        self.answerFont = giniConfiguration.textStyleFonts[.body2] ?? giniConfiguration.customFont.regular
        self.answerAttributedText = NSAttributedString(string: answerText,
                                             attributes: [.font: answerFont, .paragraphStyle: paragraphStyle])
    }
}

extension PaymentInfoAnswerTableViewCell {
    private enum Constants {
        static let bottomPadding = 16.0
    }
}

extension PaymentInfoAnswerTableViewModel {
    private enum Constants {
        static let lineHeight = 1.32
        static let paragraphSpacing = 10.0
    }
}
