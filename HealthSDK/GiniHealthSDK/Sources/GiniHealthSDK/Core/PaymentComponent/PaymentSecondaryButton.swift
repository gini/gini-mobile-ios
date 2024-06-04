//
//  PaymentSecondaryButton.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PaymentSecondaryButton: UIView {
    
    private var giniHealthConfiguration = GiniHealthConfiguration.shared
    
    var didTapButton: (() -> Void)?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    init() {
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
            rightImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constants.bankNameChevronIconPadding)
        ])
    }
    
    private func activateBankImageViewConstraints(isPaymentProviderInstalled: Bool) {
        if isPaymentProviderInstalled {
            leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentLeadingPadding).isActive = true
            leftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            leftImageView.widthAnchor.constraint(equalToConstant: leftImageView.frame.width).isActive = true
            leftImageView.heightAnchor.constraint(equalToConstant: leftImageView.frame.height).isActive = true
            let bankNameBankViewConstraint = titleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: Constants.contentLeadingPadding)
            bankNameBankViewConstraint.priority = .required - 1 // fix needed because of embeded views in cells issue. We need this to silent the "Unable to simultaneously satisfy constraints" warning
            bankNameBankViewConstraint.isActive = true
            leftImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        } else {
            let bankNameLeadingSuperviewConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentLeadingPadding)
            bankNameLeadingSuperviewConstraint.priority = .required - 1
            bankNameLeadingSuperviewConstraint.isActive = true
            contentView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        }
    }
    
    @objc
    private func tapOnBankPicker() {
        didTapButton?()
    }
}

extension PaymentSecondaryButton {
    func configure(with configuration: ButtonConfiguration) {
        contentView.layer.cornerRadius = configuration.cornerRadius
        contentView.layer.borderWidth = configuration.borderWidth
        contentView.layer.borderColor = configuration.borderColor.cgColor
        contentView.backgroundColor = configuration.backgroundColor
        
        leftImageView.layer.borderColor = configuration.borderColor.cgColor
        leftImageView.layer.borderWidth = configuration.borderWidth
        leftImageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)
        
        titleLabel.textColor = configuration.titleColor
        if let inputFont = giniHealthConfiguration.textStyleFonts[.input] {
            titleLabel.font = inputFont
        }
    }
    
    func customConfigure(labelText: String, leftImageIcon: UIImage?, rightImageIcon: String?, rightImageTintColor: UIColor, isPaymentProviderInstalled: Bool, notInstalledTextColor: UIColor) {
        if let leftImageIcon, isPaymentProviderInstalled {
            leftImageView.image = leftImageIcon
            leftImageView.isHidden = false
        } else {
            leftImageView.isHidden = true
        }
        if let rightImageIcon {
            rightImageView.image = UIImageNamedPreferred(named: rightImageIcon)?.withRenderingMode(.alwaysTemplate)
            rightImageView.tintColor = rightImageTintColor
            rightImageView.isHidden = false
        } else {
            rightImageView.isHidden = true
        }
        titleLabel.text = labelText
        if !isPaymentProviderInstalled {
            titleLabel.textColor = notInstalledTextColor
        }
        activateBankImageViewConstraints(isPaymentProviderInstalled: isPaymentProviderInstalled)
    }
}

extension PaymentSecondaryButton {
    enum Constants {
        static let bankIconSize: CGFloat = 32
        static let bankIconCornerRadius: CGFloat = 6
        static let chevronIconSize: CGFloat = 24
        static let contentTrailingPadding: CGFloat = 16
        static let bankNameChevronIconPadding: CGFloat = 10
        static let contentLeadingPadding: CGFloat = 16
    }
}
