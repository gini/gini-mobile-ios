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
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var moreInformationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        return stackView
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
                                                          action: #selector(tapOnMoreInformationAction(gesture:)))
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
        return button
    }()
    
    private lazy var selectBankView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .max, height: 185)
        return view
    }()
    
    private lazy var selectBankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.selectBankLabelText
        label.textColor = viewModel.selectBankAccentColor
        label.font = viewModel.selectBankLabelFont
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var selectBankPickerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .max, height: 56)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = viewModel.selectBankPickerViewBorderColor.cgColor
        view.backgroundColor = viewModel.selectBankPickerViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnBankPicker)))
        return view
    }()
    
    private lazy var bankImageView: UIImageView = {
        let image = UIImageNamedPreferred(named: viewModel.bankImageIconName)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
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
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var chevronDownIconView: UIImageView = {
        let image = UIImageNamedPreferred(named: viewModel.chevronDownIconName)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var payBillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .max, height: 56)
        view.layer.cornerRadius = 12
        view.backgroundColor = viewModel.payBillViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnPayBillView)))
        return view
    }()
    
    private lazy var payBillLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.payBillLabelText
        label.textColor = viewModel.payBillLabelAccentColor
        label.font = viewModel.payBillLabelFont
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var poweredByGiniView: PoweredByGiniView = {
        let view = PoweredByGiniView()
        view.viewModel = PoweredByGiniViewModel(giniConfiguration: viewModel.giniConfiguration)
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
        self.frame = CGRect(x: 0, y: 0, width: .max, height: 240)
        
        self.backgroundColor = viewModel.backgroundColor
        
        self.addSubview(contentStackView)
        
        // Content StackView Constraints
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4)
        ])

        contentStackView.addArrangedSubview(moreInformationStackView)
        contentStackView.addArrangedSubview(selectBankView)
        setupMoreInformationView()
        setupSelectBankView()
        setupBankPickerView()
        setupPayBillView()
    }
    
    private func setupMoreInformationView() {
        // We need our label into a view for layout purposes. Stackviews require views in order to satisfy all dynamic constraints
        let moreInformationLabelView = UIView()
        moreInformationLabelView.addSubview(moreInformationLabel)
        NSLayoutConstraint.activate([
            moreInformationLabel.leadingAnchor.constraint(equalTo: moreInformationLabelView.leadingAnchor),
            moreInformationLabel.trailingAnchor.constraint(equalTo: moreInformationLabelView.trailingAnchor),
            moreInformationLabel.centerYAnchor.constraint(equalTo: moreInformationLabelView.centerYAnchor)
        ])
        moreInformationStackView.addArrangedSubview(moreInformationLabelView)
        moreInformationStackView.addArrangedSubview(moreInformationButton)
    }
    
    private func setupSelectBankView() {
        selectBankView.addSubview(selectBankLabel)
        selectBankView.addSubview(selectBankPickerView)
        selectBankView.addSubview(payBillView)
        selectBankView.addSubview(poweredByGiniView)
        
        NSLayoutConstraint.activate([
            selectBankView.heightAnchor.constraint(equalToConstant: selectBankView.frame.height),
            selectBankLabel.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectBankLabel.topAnchor.constraint(equalTo: selectBankView.topAnchor),
            selectBankLabel.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankPickerView.heightAnchor.constraint(equalToConstant: selectBankPickerView.frame.height),
            selectBankPickerView.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectBankPickerView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankPickerView.topAnchor.constraint(equalTo: selectBankLabel.bottomAnchor, constant: 4),
            payBillView.heightAnchor.constraint(equalToConstant: payBillView.frame.height),
            payBillView.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            payBillView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            payBillView.topAnchor.constraint(equalTo: selectBankPickerView.bottomAnchor, constant: 8),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: poweredByGiniView.frame.height),
            poweredByGiniView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            poweredByGiniView.topAnchor.constraint(equalTo: payBillView.bottomAnchor, constant: 4),
        ])
    }
    
    private func setupBankPickerView() {
        selectBankPickerView.addSubview(bankImageView)
        selectBankPickerView.addSubview(bankNameLabel)
        selectBankPickerView.addSubview(chevronDownIconView)
        
        NSLayoutConstraint.activate([
            bankImageView.leadingAnchor.constraint(equalTo: selectBankPickerView.leadingAnchor, constant: 16),
            bankImageView.centerYAnchor.constraint(equalTo: selectBankPickerView.centerYAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: bankImageView.frame.width),
            bankImageView.heightAnchor.constraint(equalToConstant: bankImageView.frame.height),
            bankNameLabel.leadingAnchor.constraint(equalTo: bankImageView.trailingAnchor, constant: 16),
            bankImageView.centerYAnchor.constraint(equalTo: bankNameLabel.centerYAnchor),
            chevronDownIconView.widthAnchor.constraint(equalToConstant: chevronDownIconView.frame.width),
            chevronDownIconView.heightAnchor.constraint(equalToConstant: chevronDownIconView.frame.height),
            selectBankPickerView.trailingAnchor.constraint(equalTo: chevronDownIconView.trailingAnchor, constant: 16),
            chevronDownIconView.centerYAnchor.constraint(equalTo: selectBankPickerView.centerYAnchor),
            bankNameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: chevronDownIconView.leadingAnchor, constant: 10)
        ])
    }
    
    private func setupPayBillView() {
        payBillView.addSubview(payBillLabel)
        
        NSLayoutConstraint.activate([
            payBillView.centerYAnchor.constraint(equalTo: payBillLabel.centerYAnchor),
            payBillView.leadingAnchor.constraint(equalTo: payBillLabel.leadingAnchor, constant: 10),
            payBillView.trailingAnchor.constraint(equalTo: payBillLabel.trailingAnchor, constant: 10)
        ])
    }
    
    @objc
    private func tapOnMoreInformationAction(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: moreInformationLabel,
                                               targetText: viewModel.moreInformationActionablePartText) {
            viewModel.tapOnMoreInformation()
        }
    }
    
    @objc
    private func tapOnBankPicker() {
        viewModel.tapOnBankPicker()
    }
    
    @objc
    private func tapOnPayBillView() {
        viewModel.tapOnPayBillView()
    }
}
