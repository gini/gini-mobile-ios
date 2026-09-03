//
//  AttachmentView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit
import GiniBankSDK
import GiniCaptureSDK

class AttachmentView: UIView {
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = GiniColor(light: .GiniBank.dark7, dark: .GiniBank.light6).uiColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackViewSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let configuration = GiniBankConfiguration.shared

    private(set) var data: Attachment?

    init(data: Attachment) {
        super.init(frame: .zero)
        self.data = data
        setupViews()
        setupConstraints()
        configure(with: data)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(with attachment: Attachment) {
        iconImageView.image = attachment.type.icon

        fileNameLabel.text = attachment.filename
    }

    private func setupViews() {
        layer.cornerRadius = Constants.viewCornerRadius

        // Add a border
        layer.borderWidth = Constants.viewBorderWidth
        layer.borderColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor().cgColor

        // Add `iconImageView` to `imageContainerView`
        imageContainerView.addSubview(iconImageView)

        // Add `imageContainerView` and `fileNameLabel` to `containerStackView`
        containerStackView.addArrangedSubview(imageContainerView)
        containerStackView.addArrangedSubview(fileNameLabel)

        // Add `containerStackView` to the view
        addSubview(containerStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            iconImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),

            // Image container size constraints
            imageContainerView.widthAnchor.constraint(equalToConstant: Constants.iconImageViewSize),
            imageContainerView.heightAnchor.constraint(equalToConstant: Constants.iconImageViewSize),

            // Stack view constraints
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                        constant: Constants.stackViewHorizontalSpacing),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                         constant: -Constants.stackViewHorizontalSpacing),
            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                                    constant: Constants.stackViewVerticalSpacing),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                                       constant: -Constants.stackViewVerticalSpacing),

            heightAnchor.constraint(equalToConstant: Constants.viewHeight),
            widthAnchor.constraint(equalToConstant: Constants.viewWidth)
        ])
    }
}

private extension AttachmentView {
    enum Constants {
        static let iconImageViewSize: CGFloat = 20 // Image size
        static let imagePadding: CGFloat = 4 // Top and bottom padding for container
        static let stackViewHorizontalSpacing: CGFloat = 8
        static let stackViewVerticalSpacing: CGFloat = 4
        static let stackViewSpacing: CGFloat = 4
        static let viewCornerRadius: CGFloat = 14
        static let viewHeight: CGFloat = 28
        static let viewWidth: CGFloat = 138
        static let viewBorderWidth: CGFloat = 1.0
    }
}
