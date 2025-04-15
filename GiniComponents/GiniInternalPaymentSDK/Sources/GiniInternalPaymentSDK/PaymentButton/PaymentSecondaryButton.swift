//
//  PaymentSecondaryButton.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class PaymentSecondaryButton: UIView {
    public var didTapButton: (() -> Void)?

    private lazy var contentView: UIView = {
        let view = EmptyView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnBankPicker)))
        return view
    }()

    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.bankIconSize, height: Constants.bankIconSize)
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.chevronIconSize, height: Constants.chevronIconSize)
        return imageView
    }()
    
    public override var canBecomeFocused: Bool {
        true
    }

    public init() {
        super.init(frame: .zero)
        addSubview(contentView)
        contentView.addSubview(leftImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightImageView)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rightImageView.widthAnchor.constraint(equalToConstant: rightImageView.frame.width),
            rightImageView.heightAnchor.constraint(equalToConstant: rightImageView.frame.height),
            contentView.trailingAnchor.constraint(equalTo: rightImageView.trailingAnchor, constant: Constants.contentTrailingPadding),
            rightImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    private func activateImagesViewConstraints() {
        if !leftImageView.isHidden {
            leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentPadding).isActive = true
            leftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            leftImageView.widthAnchor.constraint(equalToConstant: leftImageView.frame.width).isActive = true
            leftImageView.heightAnchor.constraint(equalToConstant: leftImageView.frame.height).isActive = true

            titleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: Constants.contentPadding).isActive = true
            leftImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        } else {
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentPadding).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }
        if titleLabel.isHidden {
            rightImageView.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: Constants.bankIconChevronIconPadding).isActive = true
        } else {
            rightImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        }
    }

    @objc
    private func tapOnBankPicker() {
        didTapButton?()
    }
}

public extension PaymentSecondaryButton {
    func configure(with configuration: ButtonConfiguration) {
        contentView.layer.cornerRadius = configuration.cornerRadius
        contentView.layer.borderWidth = configuration.borderWidth
        contentView.layer.borderColor = configuration.borderColor.cgColor
        contentView.backgroundColor = configuration.backgroundColor

        leftImageView.layer.borderColor = configuration.borderColor.cgColor
        leftImageView.layer.borderWidth = configuration.borderWidth
        leftImageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)

        titleLabel.textColor = configuration.titleColor
        titleLabel.font = configuration.titleFont
    }

    func customConfigure(labelText: String, leftImageIcon: UIImage?, rightImageIcon: UIImage?, rightImageTintColor: UIColor?, shouldShowLabel: Bool) {
        if let leftImageIcon {
            leftImageView.image = leftImageIcon
            leftImageView.isHidden = false
        } else {
            leftImageView.isHidden = true
        }
        if let rightImageIcon {
            rightImageView.image = rightImageIcon.withRenderingMode(.alwaysTemplate)
            rightImageView.tintColor = rightImageTintColor
            rightImageView.isHidden = false
        } else {
            rightImageView.isHidden = true
        }
        if shouldShowLabel {
            titleLabel.text = labelText
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
        activateImagesViewConstraints()
    }
}

extension PaymentSecondaryButton {
    enum Constants {
        static let bankIconSize: CGFloat = 32
        static let bankIconCornerRadius: CGFloat = 6
        static let chevronIconSize: CGFloat = 24
        static let contentTrailingPadding: CGFloat = 16
        static let bankIconChevronIconPadding: CGFloat = 12
        static let contentPadding: CGFloat = 12
    }
}
