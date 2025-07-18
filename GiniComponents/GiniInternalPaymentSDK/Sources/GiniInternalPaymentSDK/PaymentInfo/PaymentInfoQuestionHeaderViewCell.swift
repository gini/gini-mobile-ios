//
//  PaymentInfoQuestionHeaderViewCell.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

final class PaymentInfoQuestionHeaderViewCell: UIView {
    var didTapSelectButton: (() -> Void)?
    
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
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var extendedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.imageSize, height: Constants.imageSize)
        return imageView
    }()
    
    override var canBecomeFocused: Bool {
        true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(extendedImageView)
        setupConstraints()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnView)))
        accessibilityElements = [titleLabel, extendedImageView]
        accessibilityTraits = .button
        isAccessibilityElement = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configureView(viewModel: PaymentInfoQuestionHeaderViewModel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.titleLineHeight
        titleLabel.attributedText = NSMutableAttributedString(string: viewModel.titleText,
                                                              attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        titleLabel.textColor = viewModel.titleColor
        titleLabel.font = viewModel.titleFont
        extendedImageView.image = viewModel.extendedIcon
        extendedImageView.tintColor = viewModel.iconTintColor
        accessibilityLabel = viewModel.titleText
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Constants.contentPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                               constant: -Constants.contentPadding),
            extendedImageView.widthAnchor.constraint(equalToConstant: extendedImageView.frame.width),
            extendedImageView.heightAnchor.constraint(equalToConstant: extendedImageView.frame.height),
            extendedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            extendedImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor,
                                                       constant: Constants.titleRightPadding),
            extendedImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @objc private func tappedOnView() {
        didTapSelectButton?()
    }
}

struct PaymentInfoQuestionHeaderViewModel {
    let titleText: String
    let titleFont: UIFont
    let titleColor: UIColor
    let extendedIcon: UIImage
    let iconTintColor: UIColor


    init(titleText: String, titleFont: UIFont, titleColor: UIColor, extendedIcon: UIImage, iconTintColor: UIColor) {
        self.titleText = titleText
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.extendedIcon = extendedIcon.withRenderingMode(.alwaysTemplate)
        self.iconTintColor = iconTintColor
    }
}

extension PaymentInfoQuestionHeaderViewCell {
    private enum Constants {
        static let titleLineHeight = 1.15
        static let titleRightPadding = 16.0
        static let imageSize = 24.0
        static let contentPadding = 16.0
    }
}
