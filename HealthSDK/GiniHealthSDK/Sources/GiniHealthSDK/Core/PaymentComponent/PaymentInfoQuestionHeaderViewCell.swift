//
//  PaymentInfoQuestionHeaderViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PaymentInfoQuestionHeaderViewCell: UIView {
    var didTapSelectButton: (() -> Void) = {}
    
    var headerViewModel: PaymentInfoQuestionHeaderViewModel? {
        didSet {
            guard let headerViewModel else { return }
            configureView(viewModel: headerViewModel)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var extendedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.imageSize, height: Constants.imageSize)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(extendedImageView)
        setupConstraints()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnView)))
    }

    private func configureView(viewModel: PaymentInfoQuestionHeaderViewModel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.titleLineHeight
        titleLabel.attributedText = NSMutableAttributedString(string: viewModel.titleText,
                                                              attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        titleLabel.textColor = viewModel.titleTextColor
        titleLabel.font = viewModel.titleFont
        extendedImageView.image = UIImageNamedPreferred(named: viewModel.extendedIconName)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.titleRightPadding),
            extendedImageView.widthAnchor.constraint(equalToConstant: extendedImageView.frame.width),
            extendedImageView.heightAnchor.constraint(equalToConstant: extendedImageView.frame.height),
            extendedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            extendedImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @objc private func tappedOnView() {
        didTapSelectButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

final class PaymentInfoQuestionHeaderViewModel {
    var titleText: String
    var titleFont: UIFont
    let titleTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                            darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    var extendedIconName: String
    private let plusIcon = "ic_plus"
    private let minusIcon = "ic_minus"
    
    init(title: String, isExtended: Bool) {
        self.titleText = title
        let giniConfiguration = GiniHealthConfiguration.shared
        self.titleFont = giniConfiguration.textStyleFonts[.body1] ?? giniConfiguration.customFont.regular
        self.extendedIconName = isExtended ? minusIcon : plusIcon
    }
}

extension PaymentInfoQuestionHeaderViewCell {
    private enum Constants {
        static let titleLineHeight = 1.15
        static let titleRightPadding = 85.0
        static let imageSize = 24.0
    }
}
