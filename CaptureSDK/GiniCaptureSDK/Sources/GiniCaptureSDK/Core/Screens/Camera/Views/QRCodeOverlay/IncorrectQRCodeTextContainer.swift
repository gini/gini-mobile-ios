//
//  IncorrectQRCodeTextContainer.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

final class IncorrectQRCodeTextContainer: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .GiniCapture.dark1
        label.text = Strings.title
        label.enableScaling()
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .GiniCapture.dark1
        label.numberOfLines = 0
        label.text = Strings.description
        label.enableScaling()
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let textStackView = UIStackView()
        configureTextStackView(textStackView)
        return textStackView
    }()

    private func configureTextStackView(_ stackView: UIStackView) {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = Constants.spacing
        stackView.backgroundColor = .GiniCapture.warning3
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constants.stackViewMargins
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear
        addSubview(scrollView)
        scrollView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // textStackView inside scrollView
            textStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            textStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            textStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private struct Constants {
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        static let expandedSpacing: CGFloat = 16
        static let stackViewMargins = UIEdgeInsets(top: expandedSpacing,
                                                   left: expandedSpacing,
                                                   bottom: expandedSpacing,
                                                   right: expandedSpacing)
    }

    private struct Strings {
        static let title = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.incorrect.title",
                                                            comment: "Unknown QR")
        static let description = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.incorrect.description",
                                                                  comment: "No content")
    }
}
