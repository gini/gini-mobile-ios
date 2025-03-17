//
//  QREngagementIngredientBrandView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class QREngagementIngredientBrandView: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var ingredientBrandLabel: UILabel = {
        let label = UILabel()
        label.text = "Powered by"
        // TODO: body-xs
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: UIColor.GiniCapture.dark6,
                                    dark: UIColor.GiniCapture.dark7).uiColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var ingredientBrandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniCaptureImages.ingredientBrand.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var ingredientBrandStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ingredientBrandLabel, ingredientBrandImageView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = Constants.ingredientBrandSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(ingredientBrandStackView)
        NSLayoutConstraint.activate([
            ingredientBrandStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topSpacing),
            ingredientBrandStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                         constant: -Constants.horizontalPadding),
            ingredientBrandStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private extension QREngagementIngredientBrandView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let topSpacing: CGFloat = 6
        static let ingredientBrandSpacing: CGFloat = 4
    }
}
