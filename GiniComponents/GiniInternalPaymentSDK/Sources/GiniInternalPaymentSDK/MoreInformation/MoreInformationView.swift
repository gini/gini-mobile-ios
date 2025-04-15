//
//  MoreInformationView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class MoreInformationView: UIButton {
    private let viewModel: MoreInformationViewModel
    
    private lazy var mainContainer: EmptyView = {
        let view = EmptyView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
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
        return label
    }()
    
    private lazy var moreInformationIcon: UIImageView = {
        let imageView = UIImageView(image: viewModel.configuration.moreInformationIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = viewModel.configuration.moreInformationAccentColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public init(viewModel: MoreInformationViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(tapOnMoreInformationButtonAction), for: .touchUpInside)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        mainContainer.isUserInteractionEnabled = false
        mainContainer.addSubview(moreInformationIcon)
        mainContainer.addSubview(moreInformationLabel)
        self.addSubview(mainContainer)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            moreInformationIcon.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            moreInformationIcon.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor),
            moreInformationIcon.widthAnchor.constraint(equalToConstant: Constants.infoIconSize),
            moreInformationIcon.heightAnchor.constraint(equalToConstant: Constants.infoIconSize),
            moreInformationLabel.leadingAnchor.constraint(equalTo: moreInformationIcon.trailingAnchor, constant: Constants.spacingPadding),
            moreInformationLabel.centerYAnchor.constraint(equalTo: moreInformationIcon.centerYAnchor),
            moreInformationLabel.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainContainer.topAnchor.constraint(equalTo: topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc
    private func tapOnMoreInformationButtonAction() {
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
