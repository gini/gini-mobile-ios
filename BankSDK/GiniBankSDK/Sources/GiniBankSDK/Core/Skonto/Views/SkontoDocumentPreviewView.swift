//
//  SkontoDocumentPreviewView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

protocol SkontoDocumentPreviewViewDelegate: AnyObject {
    func documentPreviewTapped(in view: SkontoDocumentPreviewView)
}

class SkontoDocumentPreviewView: UIButton {
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().placeholder.background.uiColor()
        view.layer.cornerRadius = Constants.imageViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var documentPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniImages.invoicePlaceholderIcon.image
        imageView.tintColor = .giniColorScheme().placeholder.tint.uiColor()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var previewTitleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.invoice.title",
                                                             comment: "Invoice")
        label.text = title
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.font = previewConfiguration.textStyleFonts[.footnoteBold]
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var previewSubtitleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.invoice.subtitle",
                                                             comment: "Tap to view")
        label.text = title
        label.numberOfLines = 0
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.font = previewConfiguration.textStyleFonts[.footnote]
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniImages.chevronRight.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .giniColorScheme().container.background.uiColor()
        view.layer.cornerRadius = Constants.groupCornerRadius
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(documentPreviewTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private let previewConfiguration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel
    weak var delegate: SkontoDocumentPreviewViewDelegate?

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        configureAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityValue = "\(previewTitleLabel.text ?? "") \(previewSubtitleLabel.text ?? "")"
        addSubview(contentView)
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(documentPreviewImageView)
        textStackView.addArrangedSubview(previewTitleLabel)
        textStackView.addArrangedSubview(previewSubtitleLabel)
        contentView.addSubview(textStackView)
        contentView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                        constant: Constants.imageViewLeading),
            imageContainerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor,
                                                    constant: Constants.imageViewVerticalPadding),
            imageContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageContainerView.widthAnchor.constraint(equalToConstant: Constants.imageViewSize),
            imageContainerView.heightAnchor.constraint(equalToConstant: Constants.imageViewSize),

            documentPreviewImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor,
                                                              constant: Constants.imageViewPadding),
            documentPreviewImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor,
                                                               constant: -Constants.imageViewPadding),
            documentPreviewImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor,
                                                          constant: Constants.imageViewPadding),
            documentPreviewImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor,
                                                             constant: -Constants.imageViewPadding),

            textStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor,
                                               constant: Constants.topPadding),
            textStackView.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor,
                                                   constant: Constants.stackViewLeading),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor),
            textStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: -Constants.chevronTrailing),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func configureAccessibility() {
        isAccessibilityElement = true
        addTarget(self, action: #selector(documentPreviewTapped), for: .touchUpInside)
    }

    @objc private func documentPreviewTapped() {
        delegate?.documentPreviewTapped(in: self)
    }
}

private extension SkontoDocumentPreviewView {
    enum Constants {
        static let stackViewSpacing: CGFloat = 0
        static let imageViewSize: CGFloat = 40
        static let imageViewLeading: CGFloat = 12
        static let imageViewVerticalPadding: CGFloat = 12
        static let stackViewLeading: CGFloat = 12
        static let chevronTrailing: CGFloat = 20
        static let imageViewPadding: CGFloat = 7
        static let imageViewCornerRadius: CGFloat = 6
        static let groupCornerRadius: CGFloat = 8
        static let topPadding: CGFloat = 12
    }
}
