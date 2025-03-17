//
//  QREngagementBrandView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class QREngagementBrandView: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var poweredByLabel: UILabel = {
        let label = UILabel()
        label.text = "Powered by"
        // TODO: body-xs
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: UIColor.GiniCapture.dark6,
                                    dark: UIColor.GiniCapture.dark7).uiColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var poweredByImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniCaptureImages.poweredByGiniLogo.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var poweredByStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [poweredByLabel, poweredByImageView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = Constants.poweredBySpacing
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
        addSubview(poweredByStackView)
        NSLayoutConstraint.activate([
            poweredByStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topSpacing),
            poweredByStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                         constant: -Constants.horizontalPadding),
            poweredByStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private extension QREngagementBrandView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let topSpacing: CGFloat = 6
        static let poweredBySpacing: CGFloat = 4
    }
}
