//
//  QREducationLoadingView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class QREducationLoadingView: UIView {
    private let giniConfiguration = GiniConfiguration.shared

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = giniConfiguration.textStyleFonts[.bodyBold]
        label.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isAccessibilityElement = true
        return label
    }()

    private lazy var analysingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = giniConfiguration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniCapture.dark6, dark: .GiniCapture.dark7).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isAccessibilityElement = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(imageView)
        addSubview(textLabel)
        addSubview(analysingLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                           constant: Constants.imageToTextSpacing),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            analysingLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                                constant: Constants.imageToAnalysingSpacing),
            analysingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            analysingLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            analysingLabel.topAnchor.constraint(greaterThanOrEqualTo: textLabel.bottomAnchor,
                                                constant: Constants.minTextToAnalysingSpacing),
            analysingLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with model: QREducationLoadingItem) {
        imageView.image = model.image
        textLabel.text = model.text
        textLabel.accessibilityLabel = model.text
        let analysingText = NSLocalizedStringPreferredFormat("ginicapture.analysis.education.loadingText",
                                                             comment: "analyzing")
        analysingLabel.text = analysingText
        analysingLabel.accessibilityLabel = analysingText
    }
}

private extension QREducationLoadingView {
    enum Constants {
        static let imageToTextSpacing: CGFloat = 16
        static let imageToAnalysingSpacing: CGFloat = 98
        static let minTextToAnalysingSpacing: CGFloat = 16
    }
}
