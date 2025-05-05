//
//  MoreInformationView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class MoreInformationView: UIView {
    private let viewModel: MoreInformationViewModel
    private let mainContainer = EmptyView()
    
    private lazy var moreInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: viewModel.configuration.moreInformationTextColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: viewModel.configuration.moreInformationLinkFont
        ]
        let moreInformationActionableAttributtedString = NSMutableAttributedString(string: viewModel.strings.moreInformationActionablePartText, attributes: attributes)
        label.attributedText = moreInformationActionableAttributtedString
        
        let tapOnMoreInformation = UITapGestureRecognizer(target: self,
                                                          action: #selector(self.tapOnMoreInformationLabelAction(gesture:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapOnMoreInformation)
        
        label.attributedText = moreInformationActionableAttributtedString
        return label
    }()
    
    private lazy var moreInformationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isAccessibilityElement = false
        button.setImage(viewModel.configuration.moreInformationIcon, for: .normal)
        button.tintColor = viewModel.configuration.moreInformationAccentColor
        button.addTarget(self, action: #selector(tapOnMoreInformationButtonAction), for: .touchUpInside)
        return button
    }()
    
    public init(viewModel: MoreInformationViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        mainContainer.addSubview(moreInformationButton)
        mainContainer.addSubview(moreInformationLabel)
        self.addSubview(mainContainer)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            moreInformationButton.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            moreInformationButton.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor),
            moreInformationButton.widthAnchor.constraint(equalToConstant: Constants.infoIconSize),
            moreInformationButton.heightAnchor.constraint(equalToConstant: Constants.infoIconSize),
            moreInformationLabel.leadingAnchor.constraint(equalTo: moreInformationButton.trailingAnchor, constant: Constants.spacingPadding),
            moreInformationLabel.centerYAnchor.constraint(equalTo: moreInformationButton.centerYAnchor),
            moreInformationLabel.trailingAnchor.constraint(greaterThanOrEqualTo: mainContainer.trailingAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainContainer.topAnchor.constraint(equalTo: topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc
    private func tapOnMoreInformationLabelAction(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: moreInformationLabel,
                                               targetText: viewModel.strings.moreInformationActionablePartText) {
            viewModel.tapOnMoreInformation()
        }
    }
    
    @objc
    private func tapOnMoreInformationButtonAction(gesture: UITapGestureRecognizer) {
        viewModel.tapOnMoreInformation()
    }
}

extension MoreInformationView {
    private enum Constants {
        static let buttonPadding = 10.0
        static let spacingPadding = 8.0
        static let infoIconSize = 24.0
    }
}
