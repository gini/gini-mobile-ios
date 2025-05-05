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

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, textLabel])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(stackView)
        addSubview(analysingLabel)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.padding),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.padding),

            analysingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            analysingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.padding),
            analysingLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.padding),
            analysingLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor,
                                               constant: Constants.imageToAnalysingLabelMinSpacing),
            analysingLabel.topAnchor.constraint(greaterThanOrEqualTo: textLabel.bottomAnchor,
                                               constant: Constants.textToAnalysingLabelMinSpacing)
        ])
    }

    func configure(with model: QREducationLoadingModel) {
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
        static let padding: CGFloat = 16
        static let stackSpacing: CGFloat = 16
        static let imageToAnalysingLabelMinSpacing: CGFloat = 100
        static let textToAnalysingLabelMinSpacing: CGFloat = 38
    }
}
