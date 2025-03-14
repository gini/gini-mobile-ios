//
//  QREngagementStepViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class QREngagementStepViewController: UIViewController {
    private let step: QREngagementStep
    private let configuration = GiniConfiguration.shared

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        // TODO: check title2Bold in configuration
        label.font = configuration.textStyleFonts[.title2Bold]
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.callout]
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(step: QREngagementStep) {
        self.step = step
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        configure(with: step)
    }

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.imageTopSpacing),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.titleTopSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                  constant: Constants.descriptionTopSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: Constants.horizontalPadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -Constants.horizontalPadding),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor,
                                                     constant: -Constants.descriptionBottomPadding)
        ])
    }

    private func configure(with step: QREngagementStep) {
        titleLabel.text = step.title
        descriptionLabel.attributedText = step.attributedDescription
        imageView.image = step.image
    }
}

private extension QREngagementStepViewController {
    enum Constants {
        static let imageTopSpacing: CGFloat = 40
        static let imageSize: CGFloat = 160
        static let titleTopSpacing: CGFloat = 24
        static let descriptionTopSpacing: CGFloat = 12
        static let descriptionBottomPadding: CGFloat = 40
        static let horizontalPadding: CGFloat = 16
    }
}
