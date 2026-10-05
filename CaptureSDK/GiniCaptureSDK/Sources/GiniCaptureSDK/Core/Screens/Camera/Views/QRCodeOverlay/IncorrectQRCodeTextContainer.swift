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

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constants.stackViewMargins
    }

    private lazy var scrollView: UIScrollView = {
        UIScrollView()
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

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        scrollView.giniMakeConstraints {
            $0.edges.equalToSuperview()
        }

        textStackView.giniMakeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide)
            $0.leading.equalTo(scrollView.contentLayoutGuide)
            $0.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView)
        }
    }

    private enum Constants {
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
