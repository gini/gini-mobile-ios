//
//  PoweredByGiniView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PoweredByGiniView: UIView {
    
    var viewModel: PoweredByGiniViewModel! {
        didSet {
            setupView()
        }
    }
    
    private lazy var poweredByGiniView: UIView = {
        EmptyView()
    }()
    
    private lazy var poweredByGiniLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.poweredByGiniLabelText
        label.textColor = viewModel.poweredByGiniLabelAccentColor
        label.font = viewModel.poweredByGiniLabelFont
        label.numberOfLines = Constants.textNumberOfLines
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var giniImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.giniIcon)
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.widthGiniLogo, height: Constants.heightGiniLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        poweredByGiniView.addSubview(poweredByGiniLabel)
        poweredByGiniView.addSubview(giniImageView)
        self.addSubview(poweredByGiniView)
        
        NSLayoutConstraint.activate([
            poweredByGiniView.trailingAnchor.constraint(equalTo: trailingAnchor),
            poweredByGiniView.leadingAnchor.constraint(equalTo: leadingAnchor),
            poweredByGiniView.topAnchor.constraint(equalTo: topAnchor),
            poweredByGiniView.bottomAnchor.constraint(equalTo: bottomAnchor),
            poweredByGiniView.trailingAnchor.constraint(equalTo: giniImageView.trailingAnchor),
            giniImageView.leadingAnchor.constraint(equalTo: poweredByGiniLabel.trailingAnchor, constant: Constants.spacingImageText),
            poweredByGiniLabel.centerYAnchor.constraint(equalTo: giniImageView.centerYAnchor),
            poweredByGiniLabel.leadingAnchor.constraint(equalTo: poweredByGiniView.leadingAnchor),
            poweredByGiniLabel.topAnchor.constraint(equalTo: poweredByGiniView.topAnchor),
            poweredByGiniLabel.bottomAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor),
            giniImageView.heightAnchor.constraint(equalToConstant: giniImageView.frame.height),
            giniImageView.widthAnchor.constraint(equalToConstant: giniImageView.frame.width),
            giniImageView.topAnchor.constraint(equalTo: poweredByGiniView.topAnchor, constant: Constants.imageTopBottomPadding),
            giniImageView.bottomAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor, constant: -Constants.imageTopBottomPadding)
        ])
    }
}

extension PoweredByGiniView {
    private enum Constants {
        static let imageTopBottomPadding = 3.0
        static let spacingImageText = 4.0
        static let widthGiniLogo = 28.0
        static let heightGiniLogo = 18.0
        static let textNumberOfLines = 1
    }
}
