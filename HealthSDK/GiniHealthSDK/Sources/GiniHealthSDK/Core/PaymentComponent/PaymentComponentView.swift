//
//  PaymentComponentView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PaymentComponentView: UIView {
    
    var viewModel: PaymentComponentViewModel! {
        didSet {
            setupView()
        }
    }
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = Constants.contentStackViewSpacing
        return stackView
    }()
    
    private lazy var moreInformationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        return stackView
    }()

    // We need our label into a view for layout purposes. Stackviews require views in order to satisfy all dynamic constraints
    private lazy var moreInformationLabelView: UIView = {
        return UIView()
    }()

    private lazy var moreInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = viewModel.moreInformationAccentColor
        label.font = viewModel.moreInformationLabelFont
        label.numberOfLines = 0
        label.text = viewModel.moreInformationLabelText
        
        let moreInformationActionableAttributtedString = NSMutableAttributedString(string: viewModel.moreInformationLabelText)
        let moreInformationPartString = (viewModel.moreInformationLabelText as NSString).range(of: viewModel.moreInformationActionablePartText)
        moreInformationActionableAttributtedString.addAttribute(.foregroundColor, 
                                                                value: viewModel.moreInformationAccentColor,
                                                                range: moreInformationPartString)
        moreInformationActionableAttributtedString.addAttribute(NSAttributedString.Key.underlineStyle, 
                                                                value: NSUnderlineStyle.single.rawValue,
                                                                range: moreInformationPartString)
        moreInformationActionableAttributtedString.addAttribute(NSAttributedString.Key.font, 
                                                                value: viewModel.moreInformationLabelLinkFont,
                                                                range: moreInformationPartString)
        label.attributedText = moreInformationActionableAttributtedString

        let tapOnMoreInformation = UITapGestureRecognizer(target: self, 
                                                          action: #selector(tapOnMoreInformationLabelAction(gesture:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapOnMoreInformation)
        
        label.attributedText = moreInformationActionableAttributtedString
        return label
    }()
    
    private lazy var moreInformationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImageNamedPreferred(named: viewModel.moreInformationIconName)
        button.setImage(image, for: .normal)
        button.tintColor = viewModel.moreInformationAccentColor
        button.addTarget(self, action: #selector(tapOnMoreInformationButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectBankView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.bankViewHeight)
        return view
    }()
    
    private lazy var selectYourBankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.selectYourBankLabelText
        label.textColor = viewModel.selectYourBankAccentColor
        label.font = viewModel.selectYourBankLabelFont
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var selectBankPickerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.selectBankViewHeight)
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = viewModel.selectBankPickerViewBorderColor.cgColor
        view.backgroundColor = viewModel.selectBankPickerViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnBankPicker)))
        return view
    }()
    
    private lazy var bankImageView: UIImageView = {
        let image = viewModel.bankImageIcon
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.bankIconSize, height: Constants.bankIconSize)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var bankNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.bankNameLabelText
        label.textColor = viewModel.bankNameLabelAccentColor
        label.font = viewModel.bankNameLabelFont
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var chevronDownIconView: UIImageView = {
        let image = UIImageNamedPreferred(named: viewModel.chevronDownIconName)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.chevronIconSize, height: Constants.chevronIconSize)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var payInvoiceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.payInvoiceViewHeight)
        view.layer.cornerRadius = Constants.cornerRadius
        view.isUserInteractionEnabled = viewModel.isPaymentProviderInstalled
        view.backgroundColor = viewModel.payInvoiceViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnPayInvoiceView)))
        return view
    }()
    
    private lazy var payInvoiceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.payInvoiceLabelText
        label.textColor = viewModel.payInvoiceLabelAccentColor
        label.font = viewModel.payInvoiceLabelFont
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var poweredByGiniView: PoweredByGiniView = {
        let view = PoweredByGiniView()
        view.viewModel = PoweredByGiniViewModel()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.viewHeight)

        self.backgroundColor = viewModel.backgroundColor
        
        self.addSubview(contentStackView)

        contentStackView.addArrangedSubview(moreInformationStackView)
        contentStackView.addArrangedSubview(selectBankView)
        moreInformationLabelView.addSubview(moreInformationLabel)
        moreInformationStackView.addArrangedSubview(moreInformationLabelView)
        moreInformationStackView.addArrangedSubview(moreInformationButton)
        selectBankView.addSubview(selectYourBankLabel)
        selectBankView.addSubview(selectBankPickerView)
        selectBankView.addSubview(payInvoiceView)
        selectBankView.addSubview(poweredByGiniView)
        if viewModel.isPaymentProviderInstalled {
            selectBankPickerView.addSubview(bankImageView)
        }
        selectBankPickerView.addSubview(bankNameLabel)
        selectBankPickerView.addSubview(chevronDownIconView)
        payInvoiceView.addSubview(payInvoiceLabel)

        activateAllConstraints()
    }

    private func activateAllConstraints() {
        activateContentStackViewConstraints()
        activateBankViewConstraints()
        activatePayInvoiceViewConstraints()
        activatePoweredByGiniViewConstraints()
        activateMoreInformationViewConstraints()
        activateBankImageViewConstraints()
    }

    private func activateContentStackViewConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.contentTopPadding),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.contentBottomPadding)
        ])
    }

    private func activateBankViewConstraints() {
        NSLayoutConstraint.activate([
            selectBankView.heightAnchor.constraint(equalToConstant: selectBankView.frame.height),
            selectYourBankLabel.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectYourBankLabel.topAnchor.constraint(equalTo: selectBankView.topAnchor),
            selectYourBankLabel.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankPickerView.heightAnchor.constraint(equalToConstant: selectBankPickerView.frame.height),
            selectBankPickerView.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectBankPickerView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankPickerView.topAnchor.constraint(equalTo: selectYourBankLabel.bottomAnchor, constant: Constants.contentBottomPadding),
            chevronDownIconView.widthAnchor.constraint(equalToConstant: chevronDownIconView.frame.width),
            chevronDownIconView.heightAnchor.constraint(equalToConstant: chevronDownIconView.frame.height),
            selectBankPickerView.trailingAnchor.constraint(equalTo: chevronDownIconView.trailingAnchor, constant: Constants.contentTrailingPadding),
            chevronDownIconView.centerYAnchor.constraint(equalTo: selectBankPickerView.centerYAnchor),
            chevronDownIconView.leadingAnchor.constraint(equalTo: bankNameLabel.trailingAnchor, constant: Constants.bankNameChevronIconPadding)
        ])
    }

    private func activatePayInvoiceViewConstraints() {
        NSLayoutConstraint.activate([
            payInvoiceView.heightAnchor.constraint(equalToConstant: payInvoiceView.frame.height),
            payInvoiceView.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            payInvoiceView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            payInvoiceView.topAnchor.constraint(equalTo: selectBankPickerView.bottomAnchor, constant: Constants.invoicePickerBankPadding),
            payInvoiceView.centerYAnchor.constraint(equalTo: payInvoiceLabel.centerYAnchor),
            payInvoiceView.leadingAnchor.constraint(equalTo: payInvoiceLabel.leadingAnchor),
            payInvoiceView.trailingAnchor.constraint(equalTo: payInvoiceLabel.trailingAnchor)
        ])
    }

    private func activatePoweredByGiniViewConstraints() {
        NSLayoutConstraint.activate([
            poweredByGiniView.heightAnchor.constraint(equalToConstant: poweredByGiniView.frame.height),
            poweredByGiniView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            poweredByGiniView.topAnchor.constraint(equalTo: payInvoiceView.bottomAnchor, constant: Constants.contentBottomPadding)
        ])
    }

    private func activateMoreInformationViewConstraints() {
        NSLayoutConstraint.activate([
            moreInformationLabel.leadingAnchor.constraint(equalTo: moreInformationLabelView.leadingAnchor),
            moreInformationLabel.trailingAnchor.constraint(equalTo: moreInformationLabelView.trailingAnchor),
            moreInformationLabel.centerYAnchor.constraint(equalTo: moreInformationLabelView.centerYAnchor)
        ])
    }

    private func activateBankImageViewConstraints() {
        if viewModel.isPaymentProviderInstalled {
            bankImageView.leadingAnchor.constraint(equalTo: selectBankPickerView.leadingAnchor, constant: Constants.contentLeadingPadding).isActive = true
            bankImageView.centerYAnchor.constraint(equalTo: selectBankPickerView.centerYAnchor).isActive = true
            bankImageView.widthAnchor.constraint(equalToConstant: bankImageView.frame.width).isActive = true
            bankImageView.heightAnchor.constraint(equalToConstant: bankImageView.frame.height).isActive = true
            let bankNameBankViewConstraint = bankNameLabel.leadingAnchor.constraint(equalTo: bankImageView.trailingAnchor, constant: Constants.contentLeadingPadding)
            bankNameBankViewConstraint.priority = .required - 1 // fix needed because of embeded views in cells issue. We need this to silent the "Unable to simultaneously satisfy constraints" warning
            bankNameBankViewConstraint.isActive = true
            bankImageView.centerYAnchor.constraint(equalTo: bankNameLabel.centerYAnchor).isActive = true
        } else {
            let bankNameLeadingSuperviewConstraint = bankNameLabel.leadingAnchor.constraint(equalTo: selectBankPickerView.leadingAnchor, constant: Constants.contentLeadingPadding)
            bankNameLeadingSuperviewConstraint.priority = .required - 1
            bankNameLeadingSuperviewConstraint.isActive = true
            selectBankPickerView.centerYAnchor.constraint(equalTo: bankNameLabel.centerYAnchor).isActive = true
        }
    }

    @objc
    private func tapOnMoreInformationLabelAction(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: moreInformationLabel,
                                               targetText: viewModel.moreInformationActionablePartText) {
            viewModel.tapOnMoreInformation()
        }
    }

    @objc
    private func tapOnMoreInformationButtonAction(gesture: UITapGestureRecognizer) {
        viewModel.tapOnMoreInformation()
    }

    @objc
    private func tapOnBankPicker() {
        viewModel.tapOnBankPicker()
    }
    
    @objc
    private func tapOnPayInvoiceView() {
        viewModel.tapOnPayInvoiceView()
    }
}

extension PaymentComponentView {
    private enum Constants {
        static let viewHeight: CGFloat = 240
        static let bankViewHeight: CGFloat = 185
        static let selectBankViewHeight: CGFloat = 56
        static let payInvoiceViewHeight: CGFloat = 56
        static let contentStackViewSpacing: CGFloat = 12
        static let bankIconSize: CGFloat = 32
        static let chevronIconSize: CGFloat = 24
        static let contentTopPadding: CGFloat = 16
        static let contentBottomPadding: CGFloat = 4
        static let contentLeadingPadding: CGFloat = 16
        static let contentTrailingPadding: CGFloat = 16
        static let invoicePickerBankPadding: CGFloat = 8
        static let bankNameChevronIconPadding: CGFloat = 10
        static let payInvoiceLabelPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
    }
}
