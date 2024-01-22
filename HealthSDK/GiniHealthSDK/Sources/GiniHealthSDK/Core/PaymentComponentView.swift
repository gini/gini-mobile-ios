//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
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
        moreInformationActionableAttributtedString.addAttribute(.foregroundColor, value: viewModel.moreInformationAccentColor, range: moreInformationPartString)
        moreInformationActionableAttributtedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: moreInformationPartString)
        moreInformationActionableAttributtedString.addAttribute(NSAttributedString.Key.font, value: viewModel.moreInformationLabelLinkFont, range: moreInformationPartString)
        label.attributedText = moreInformationActionableAttributtedString

        let tapOnMoreInformation = UITapGestureRecognizer(target: self, action: #selector(tapOnMoreInformationAction(gesture:)))
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
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: frame.height))
        
        self.backgroundColor = viewModel.backgroundColor
        
        self.addSubview(contentStackView)
        
        // Content StackView Constraints
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        contentStackView.addArrangedSubview(moreInformationStackView)
        setupMoreInformationView()
        setupSelectBankView()
        
//        let viewTest = UIView()
//        viewTest.translatesAutoresizingMaskIntoConstraints = false
//        viewTest.frame = CGRect(x: 0, y: 0, width: .max, height: 100)
//        NSLayoutConstraint.activate([
//            viewTest.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
//        ])
//        contentStackView.addArrangedSubview(viewTest)
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
    
    @objc
    private func tapOnMoreInformationAction(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: moreInformationLabel, targetText: viewModel.moreInformationActionablePartText) {
            viewModel.tapOnMoreInformation()
        }
    }
    
    private func setupSelectBankView() {
        let selectBankView = UIView()
        selectBankView.translatesAutoresizingMaskIntoConstraints = false
        selectBankView.frame = CGRect(x: 0, y: 0, width: .max, height: 185)
        selectBankView.addSubview(selectBankLabel)
        
        selectBankView.addSubview(selectBankPickerView)
        
        NSLayoutConstraint.activate([
            selectBankView.heightAnchor.constraint(equalToConstant: selectBankView.frame.height),
            selectBankLabel.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectBankLabel.topAnchor.constraint(equalTo: selectBankView.topAnchor),
            selectBankLabel.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankPickerView.heightAnchor.constraint(equalToConstant: selectBankPickerView.frame.height),
            selectBankPickerView.leadingAnchor.constraint(equalTo: selectBankView.leadingAnchor),
            selectBankPickerView.trailingAnchor.constraint(equalTo: selectBankView.trailingAnchor),
            selectBankPickerView.topAnchor.constraint(equalTo: selectBankLabel.bottomAnchor, constant: 4)
        ])
        
        contentStackView.addArrangedSubview(selectBankView)
    }
}
