//
//  MoreInformationView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class MoreInformationView: UIView {
    var viewModel: MoreInformationViewModel! {
        didSet {
            setupView()
        }
    }
    
    private lazy var moreInformationView: UIView = {
        EmptyView()
    }()
    
    private lazy var moreInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: viewModel.moreInformationLabelTextColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: viewModel.moreInformationLabelLinkFont
        ]
        let moreInformationActionableAttributtedString = NSMutableAttributedString(string: viewModel.moreInformationActionablePartText, attributes: attributes)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        moreInformationView.addSubview(moreInformationButton)
        moreInformationView.addSubview(moreInformationLabel)
        self.addSubview(moreInformationView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            moreInformationButton.leadingAnchor.constraint(equalTo: moreInformationView.leadingAnchor),
            moreInformationButton.centerYAnchor.constraint(equalTo: moreInformationView.centerYAnchor),
            moreInformationButton.widthAnchor.constraint(equalToConstant: Constants.infoIconSize),
            moreInformationButton.heightAnchor.constraint(equalToConstant: Constants.infoIconSize),
            moreInformationLabel.leadingAnchor.constraint(equalTo: moreInformationButton.trailingAnchor, constant: Constants.spacingPadding),
            moreInformationLabel.centerYAnchor.constraint(equalTo: moreInformationButton.centerYAnchor),
            moreInformationLabel.trailingAnchor.constraint(greaterThanOrEqualTo: moreInformationView.trailingAnchor),
            moreInformationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            moreInformationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            moreInformationView.topAnchor.constraint(equalTo: topAnchor),
            moreInformationView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
}

extension MoreInformationView {
    private enum Constants {
        static let buttonPadding = 10.0
        static let spacingPadding = 8.0
        static let infoIconSize = 24.0
    }
}
