//
//  PaymentPrimaryButton.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class PaymentPrimaryButton: UIButton {
    public var didTapButton: (() -> Void)?
    
    private lazy var contentView: UIView = {
        let view = EmptyView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.bankIconSize, height: Constants.bankIconSize)
        return imageView
    }()
    
    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.bankIconSize, height: Constants.bankIconSize)
        return imageView
    }()
    
    private var trailingConstraint: NSLayoutConstraint?
    
    public init() {
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(tapOnPayInvoiceView), for: .touchUpInside)
        addSubview(contentView)
        contentView.addSubview(buttonTitleLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        trailingConstraint = contentView.trailingAnchor.constraint(equalTo: buttonTitleLabel.trailingAnchor)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.centerYAnchor.constraint(equalTo: buttonTitleLabel.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: buttonTitleLabel.leadingAnchor),
        ])
        trailingConstraint?.isActive = true
    }
        
    private func setupLeftImageConstraints() {
        leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentLeadingPadding).isActive = true
        leftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        leftImageView.widthAnchor.constraint(equalToConstant: leftImageView.frame.width).isActive = true
        leftImageView.heightAnchor.constraint(equalToConstant: leftImageView.frame.height).isActive = true
    }
    
    private func setupRightImageConstraints() {
        rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.contentTrailingPadding).isActive = true
        rightImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        rightImageView.widthAnchor.constraint(equalToConstant: rightImageView.frame.width).isActive = true
        rightImageView.heightAnchor.constraint(equalToConstant: rightImageView.frame.height).isActive = true
        trailingConstraint?.isActive = false
        buttonTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(Constants.contentTrailingPadding + Constants.bankIconSize)).isActive = true
    }
        
    @objc private func tapOnPayInvoiceView() {
        didTapButton?()
    }
}

public extension PaymentPrimaryButton {
    func configure(with configuration: ButtonConfiguration) {
        self.contentView.backgroundColor = configuration.backgroundColor
        self.contentView.layer.cornerRadius = configuration.cornerRadius
        self.contentView.layer.borderColor = configuration.borderColor.cgColor
        self.contentView.layer.shadowColor = configuration.shadowColor.cgColor

        self.buttonTitleLabel.textColor = configuration.titleColor
        self.buttonTitleLabel.font = configuration.titleFont
    }
    
    func customConfigure(text: String,
                         textColor: UIColor?,
                         backgroundColor: UIColor?,
                         leftImageData: Data? = nil,
                         rightImageData: Data? = nil) {
        contentView.backgroundColor = backgroundColor
        
        buttonTitleLabel.text = text
        buttonTitleLabel.textColor = textColor
        
        // Configure left image if provided
        if let leftImageData {
            contentView.addSubview(leftImageView)
            setupLeftImageConstraints()
            leftImageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)
            leftImageView.image = UIImage(data: leftImageData)
        }
        
        // Configure right image if provided
        if let rightImageData {
            contentView.addSubview(rightImageView)
            setupRightImageConstraints()
            rightImageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)
            rightImageView.image = UIImage(data: rightImageData)
        }
    }
}

extension PaymentPrimaryButton {
    private enum Constants {
        static let bankIconSize: CGFloat = 36
        static let bankIconCornerRadius: CGFloat = 8
        static let contentLeadingPadding: CGFloat = 19
        static let contentTrailingPadding: CGFloat = 8
    }
}
