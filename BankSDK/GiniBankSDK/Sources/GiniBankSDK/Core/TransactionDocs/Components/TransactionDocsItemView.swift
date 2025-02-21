//
//  TransactionDocsItemView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class TransactionDocsItemView: UIView {
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .giniColorScheme().placeholder.background.uiColor()
        view.layer.cornerRadius = Constants.imageViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .giniColorScheme().placeholder.tint.uiColor()
        return imageView
    }()

    private lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.body]
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.numberOfLines = Constants.fileNameLabelNumberOfLines
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(GiniImages.transactionDocsOptionsIcon.image, for: .normal)
        button.tintColor = .giniColorScheme().icon.primary.uiColor()
        button.addTarget(self, action: #selector(optionsButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageContainerView, fileNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackViewSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let configuration = GiniBankConfiguration.shared

    private(set) var transactionDocsItem: GiniTransactionDoc?

    var optionsAction: (() -> Void)?
    var tapAction: (() -> Void)?

    init(transactionDocsItem: GiniTransactionDoc) {
        super.init(frame: .zero)
        self.transactionDocsItem = transactionDocsItem
        setupViews()
        setupConstraints()
        configure(with: transactionDocsItem)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(with transactionDoc: GiniTransactionDoc) {
        iconImageView.image = transactionDoc.type.icon
        fileNameLabel.text = transactionDoc.fileName

        setupAccessibility(with: transactionDoc.fileName)
    }

    private func setupViews() {
        imageContainerView.addSubview(iconImageView)
        addSubview(containerStackView)
        addSubview(optionsButton)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        containerStackView.isUserInteractionEnabled = true
        containerStackView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupAccessibility(with fileName: String) {
        optionsButton.isAccessibilityElement = true
        optionsButton.accessibilityTraits = .button
        optionsButton.accessibilityLabel = NSLocalizedStringPreferredGiniBankFormat(
            "ginibank.transactionDocs.document.optionbutton.accessibilitylabel",
            comment: "Option button")

        imageContainerView.isAccessibilityElement = false
        fileNameLabel.isAccessibilityElement = false

        containerStackView.isAccessibilityElement = true
        let documentAccessibilityLabel = NSLocalizedStringPreferredGiniBankFormat(
            "ginibank.transactionDocs.document.accessibilitylabel",
            comment: "Tap to view")
        containerStackView.accessibilityLabel = String.localizedStringWithFormat(documentAccessibilityLabel, fileName)

        accessibilityElements = [containerStackView, optionsButton]
    }

    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageContainerView.widthAnchor.constraint(equalToConstant: Constants.imageViewSize),
            imageContainerView.heightAnchor.constraint(equalToConstant: Constants.imageViewSize),

            iconImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor,
                                                   constant: Constants.imageViewPadding),
            iconImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor,
                                                    constant: -Constants.imageViewPadding),
            iconImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor,
                                               constant: Constants.imageViewPadding),
            iconImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor,
                                                  constant: -Constants.imageViewPadding),

            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                                    constant: Constants.minimalTopAnchor),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                                       constant: Constants.minimalBottomAnchor),

            optionsButton.leadingAnchor.constraint(equalTo: containerStackView.trailingAnchor,
                                                   constant: Constants.optionsButtonLeftPaddig),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            optionsButton.widthAnchor.constraint(equalToConstant: Constants.optionsButtonSize),
            optionsButton.heightAnchor.constraint(equalToConstant: Constants.optionsButtonSize),

            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.viewMinimalHeight)
        ])
    }

    // MARK: - Actions
    @objc private func optionsButtonTapped() {
        optionsAction?()
    }

    @objc private func didTapView() {
        tapAction?()
    }
}

private extension TransactionDocsItemView {
    enum Constants {
        static let iconImageViewSize: CGFloat = 24
        static let fileNameLabelNumberOfLines: Int = 0
        static let fileNameLabelLeadingAnchor: CGFloat = 16
        static let fileNameLabelTrailingAnchor: CGFloat = -16
        static let minimalTopAnchor: CGFloat = 8
        static let minimalBottomAnchor: CGFloat = -8
        static let optionsButtonSize: CGFloat = 30
        static let optionsButtonLeftPaddig: CGFloat = 22
        static let viewMinimalHeight: CGFloat = 44
        static let imageViewPadding: CGFloat = 8
        static let imageViewCornerRadius: CGFloat = 6
        static let imageViewSize: CGFloat = 40
        static let stackViewSpacing: CGFloat = 8
    }
}
