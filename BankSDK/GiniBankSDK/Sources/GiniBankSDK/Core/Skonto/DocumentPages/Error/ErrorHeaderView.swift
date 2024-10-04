//
//  ErrorHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class ErrorHeaderView: UIView {
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .GiniBank.error3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = GiniBankConfiguration.shared.textStyleFonts[.subheadline]
        label.textColor = .GiniBank.light1
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let headerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        headerStack.addArrangedSubview(iconImageView)
        headerStack.addArrangedSubview(headerLabel)
        addSubview(headerStack)
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconImageSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconImageSize),
            headerStack.topAnchor.constraint(equalTo: topAnchor, 
                                             constant: Constants.stackViewTopPadding),
            headerStack.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                constant: Constants.stackViewBottomPadding)
        ])
    }

    private enum Constants {
        static let iconImageSize: CGFloat = 24
        static let stackViewSpacing: CGFloat = 19
        static let stackViewTopPadding: CGFloat = 20
        static let stackViewBottomPadding: CGFloat = -20
    }
}
