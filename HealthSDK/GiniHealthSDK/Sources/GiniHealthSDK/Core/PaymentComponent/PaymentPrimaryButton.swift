//
//  PaymentPrimaryButton.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

final class PaymentPrimaryButton: UIView {
    
    private var giniHealthConfiguration = GiniHealthConfiguration.shared
    
    var didTapButton: (() -> Void)?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnPayInvoiceView)))
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
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
            contentView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
        
        
    @objc private func tapOnPayInvoiceView() {
        didTapButton?()
    }
}

extension PaymentPrimaryButton {
    func configure(with configuration: ButtonConfiguration) {
        self.contentView.backgroundColor = configuration.backgroundColor
        self.contentView.layer.cornerRadius = configuration.cornerRadius
        self.contentView.layer.borderColor = configuration.borderColor.cgColor
        self.contentView.layer.shadowColor = configuration.shadowColor.cgColor

        self.titleLabel.textColor = configuration.titleColor
        
        if let buttonFont = giniHealthConfiguration.textStyleFonts[.button] {
            self.titleLabel.font = buttonFont
        }
    }
    
    func customConfigure(paymentProviderColors: ProviderColors?, isPaymentProviderInstalled: Bool, text: String) {
        if let backgroundHexColor = paymentProviderColors?.background.toColor(), isPaymentProviderInstalled {
            contentView.backgroundColor = backgroundHexColor
        }
        contentView.isUserInteractionEnabled = isPaymentProviderInstalled
        
        titleLabel.text = text
        if let textHexColor = paymentProviderColors?.text.toColor() {
            titleLabel.textColor = textHexColor
        }
    }
}
