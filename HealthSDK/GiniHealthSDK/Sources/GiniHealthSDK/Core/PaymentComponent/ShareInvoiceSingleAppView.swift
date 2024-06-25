//
//  ShareInvoiceSingleAppView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class ShareInvoiceSingleAppView: UIView {
    // Subviews
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.roundCorners(corners: .allCorners, radius: Constants.imageViewCornerRardius)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                    darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
        label.font = GiniHealthConfiguration.shared.textStyleFonts[.caption2] ?? UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    // Setup views and constraints
    private func setupViews() {
        addSubview(imageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageViewHeight),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.topAnchorTitleLabelConstraint),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // Function to configure view
    func configure(image: UIImage?, title: String?, isMoreButton: Bool) {
        imageView.image = image
        titleLabel.text = title
        imageView.layer.borderColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                darkModeColor: UIColor.GiniHealthColors.light3).uiColor().cgColor
        imageView.layer.borderWidth = isMoreButton ? 1 : 0
        imageView.backgroundColor = isMoreButton ? .clear : GiniColor(lightModeColor: .white,
                                                                      darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
        imageView.contentMode = isMoreButton ? .center : .scaleAspectFit
    }
}

extension ShareInvoiceSingleAppView {
    enum Constants {
        static let imageViewHeight = 36.0
        static let topAnchorTitleLabelConstraint = 8.0
        static let imageViewCornerRardius = 6.0
    }
}
