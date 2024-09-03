//
//  AttachmentView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class AttachmentView: UIView {
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4).uiColor()
        view.layer.cornerRadius = Constants.imageViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .giniColorScheme().icons.standardTertiary.uiColor()
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
        button.setImage(GiniImages.attachmentOptionsIcon.image, for: .normal)
        button.tintColor = .giniColorScheme().icons.standardPrimary.uiColor()
        button.addTarget(self, action: #selector(optionsButtonTapped), for: .touchUpInside)
        return button
    }()

    private let configuration = GiniBankConfiguration.shared

    private var attachment: Attachment?

    var optionsAction: (() -> Void)?

    init(attachment: Attachment) {
        super.init(frame: .zero)
        self.attachment = attachment
        setupViews()
        setupConstraints()
        configure(with: attachment)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(with attachment: Attachment) {
        iconImageView.image = attachment.type.icon
        fileNameLabel.text = attachment.fileName
    }

    private func setupViews() {
        imageContainerView.addSubview(iconImageView)
        addSubview(imageContainerView)
        addSubview(fileNameLabel)
        addSubview(optionsButton)
    }

    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                        constant: Constants.iconImageViewLeadingAnchor),
            imageContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
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

            fileNameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor,
                                                   constant: Constants.fileNameLabelLeadingAnchor),
            fileNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            fileNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: optionsButton.leadingAnchor,
                                                    constant: Constants.fileNameLabelTrailingAnchor),
            fileNameLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                                          constant: Constants.fileNameLabelMinimalTopAnchor),
            fileNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                                             constant: Constants.fileNameLabelMinimalBottomAnchor),

            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                   constant: Constants.optionsButtonTrailingAnchor),
            optionsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            optionsButton.widthAnchor.constraint(equalToConstant: Constants.optionsButtonSize),
            optionsButton.heightAnchor.constraint(equalToConstant: Constants.optionsButtonSize),

            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.viewMinimalHeight)
        ])
    }

    @objc private func optionsButtonTapped() {
        optionsAction?()
    }
}

private extension AttachmentView {
    enum Constants {
        static let iconImageViewLeadingAnchor: CGFloat = 12
        static let iconImageViewSize: CGFloat = 24
        static let fileNameLabelNumberOfLines: Int = 0
        static let fileNameLabelLeadingAnchor: CGFloat = 16
        static let fileNameLabelTrailingAnchor: CGFloat = -16
        static let fileNameLabelMinimalTopAnchor: CGFloat = 8
        static let fileNameLabelMinimalBottomAnchor: CGFloat = -8
        static let optionsButtonTrailingAnchor: CGFloat = -12
        static let optionsButtonSize: CGFloat = 30
        static let viewMinimalHeight: CGFloat = 44
        static let imageViewPadding: CGFloat = 8
        static let imageViewCornerRadius: CGFloat = 6
        static let imageViewSize: CGFloat = 40
    }
}
