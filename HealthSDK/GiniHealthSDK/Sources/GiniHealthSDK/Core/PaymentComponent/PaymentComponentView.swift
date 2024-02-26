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
        label.textColor = viewModel.moreInformationLabelTextColor
        label.font = viewModel.moreInformationLabelFont
        label.numberOfLines = 0
        label.text = viewModel.moreInformationLabelText
        
        let moreInformationActionableAttributtedString = NSMutableAttributedString(string: viewModel.moreInformationLabelText)
        let moreInformationPartString = (viewModel.moreInformationLabelText as NSString).range(of: viewModel.moreInformationActionablePartText)
        moreInformationActionableAttributtedString.addAttribute(.foregroundColor,
                                                                value: viewModel.moreInformationLabelTextColor,
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
    
    private lazy var selectBankButton: PaymentSecondaryButton = {
        let button = PaymentSecondaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.buttonViewHeight)
        button.configure(with: viewModel.giniHealthConfiguration.secondaryButtonConfiguration)
        button.customConfigure(labelText: viewModel.bankNameLabelText,
                               leftImageIcon: viewModel.bankImageIcon,
                               rightImageIcon: viewModel.chevronDownIconName,
                               rightImageTintColor: viewModel.chevronDownIconColor,
                               isPaymentProviderInstalled: viewModel.isPaymentProviderInstalled,
                               notInstalledTextColor: viewModel.notInstalledBankTextColor)
        return button
    }()
    
    private lazy var payInvoiceButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.buttonViewHeight)
        button.configure(with: viewModel.giniHealthConfiguration.primaryButtonConfiguration)
        button.customConfigure(paymentProviderColors: viewModel.paymentProviderColors, 
                               isPaymentProviderInstalled: viewModel.isPaymentProviderInstalled,
                               text: viewModel.payInvoiceLabelText)
        return button
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
        selectBankView.addSubview(selectBankButton)
        selectBankView.addSubview(payInvoiceButton)
        selectBankView.addSubview(poweredByGiniView)

        activateAllConstraints()
        setupGestures()
    }

    private func activateAllConstraints() {
        activateContentStackViewConstraints()
        activateSelectBankButtonConstraints()
        activatePayInvoiceButtonConstraints()
        activatePoweredByGiniViewConstraints()
        activateMoreInformationViewConstraints()
    }
    
    private func setupGestures() {
        payInvoiceButton.didTapButton = { [weak self] in
            self?.tapOnPayInvoiceView()
        }
        selectBankButton.didTapButton = { [weak self] in
            self?.tapOnBankPicker()
        }
    }

    private func activateContentStackViewConstraints() {
        // Content StackView Constraints
        let contentViewHeightConstraint = heightAnchor.constraint(equalToConstant: frame.height)
        contentViewHeightConstraint.priority = .required - 1 // We need this to silent warnings

        let contentViewBottomAnchorConstraint = contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4)
        contentViewBottomAnchorConstraint.priority = .required - 1

        NSLayoutConstraint.activate([
            contentViewHeightConstraint,
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.contentTopPadding),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.contentBottomPadding),
            contentViewBottomAnchorConstraint
        ])
    }

    private func activateSelectBankButtonConstraints() {
        let selectBankViewHeightConstraint = selectBankView.heightAnchor.constraint(equalToConstant: selectBankView.frame.height)
        selectBankViewHeightConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            selectBankViewHeightConstraint,
            selectYourBankLabel.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectYourBankLabel.topAnchor.constraint(equalTo: selectBankView.topAnchor),
            selectYourBankLabel.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankButton.heightAnchor.constraint(equalToConstant: selectBankButton.frame.height),
            selectBankButton.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectBankButton.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankButton.topAnchor.constraint(equalTo: selectYourBankLabel.bottomAnchor, constant: Constants.contentBottomPadding)
        ])
    }

    private func activatePayInvoiceButtonConstraints() {
        NSLayoutConstraint.activate([
            payInvoiceButton.heightAnchor.constraint(equalToConstant: payInvoiceButton.frame.height),
            payInvoiceButton.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            payInvoiceButton.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            payInvoiceButton.topAnchor.constraint(equalTo: selectBankButton.bottomAnchor, constant: Constants.invoicePickerBankPadding)
        ])
    }

    private func activatePoweredByGiniViewConstraints() {
        NSLayoutConstraint.activate([
            poweredByGiniView.heightAnchor.constraint(equalToConstant: poweredByGiniView.frame.height),
            poweredByGiniView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            poweredByGiniView.topAnchor.constraint(equalTo: payInvoiceButton.bottomAnchor, constant: Constants.contentBottomPadding)
        ])
    }

    private func activateMoreInformationViewConstraints() {
        NSLayoutConstraint.activate([
            moreInformationLabel.leadingAnchor.constraint(equalTo: moreInformationLabelView.leadingAnchor),
            moreInformationLabel.trailingAnchor.constraint(equalTo: moreInformationLabelView.trailingAnchor),
            moreInformationLabel.centerYAnchor.constraint(equalTo: moreInformationLabelView.centerYAnchor)
        ])
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
        static let buttonViewHeight: CGFloat = 56
        static let contentStackViewSpacing: CGFloat = 12
        static let bankIconSize: CGFloat = 32
        static let contentTopPadding: CGFloat = 16
        static let contentBottomPadding: CGFloat = 4
        static let invoicePickerBankPadding: CGFloat = 8
    }
}
