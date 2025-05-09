//
//  CameraNotAuthorizedView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

final class CameraNotAuthorizedView: UIView {
    // User interface
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredFormat("ginicapture.camera.notAuthorized.title",
                                                          comment: "Not authorized title")
        label.numberOfLines = 0
        label.textColor = GiniColor(light: UIColor.GiniCapture.dark1, dark: UIColor.GiniCapture.light1).uiColor()
        label.textAlignment = .center
        label.font = configuration.textStyleFonts[.title2]?.limitingFontSize(to: Constants.maximumFontSize)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredFormat("ginicapture.camera.notAuthorized.description",
                                                          comment: "Not authorized description")
        label.numberOfLines = 0
        label.textColor = UIColor.GiniCapture.dark7
        label.textAlignment = .center
        label.font = configuration.textStyleFonts[.headline]?.limitingFontSize(to: Constants.maximumFontSize)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamedPreferred(named: "cameraNotAuthorizedIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.camera.notAuthorized.title",
                                                                        comment: "Not authorized title")
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .none
        return imageView
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedStringPreferredFormat("ginicapture.camera.notAuthorizedButton.noStatus",
                                                         comment: "Grant permission"), for: .normal)
        button.setTitleColor(GiniColor(light: UIColor.GiniCapture.accent1,
                                       dark: UIColor.GiniCapture.accent1).uiColor(), for: .normal)
        button.setTitleColor(GiniColor(light: UIColor.GiniCapture.accent1,
                                       dark: UIColor.GiniCapture.accent1).uiColor().withAlphaComponent(0.8),
                             for: .highlighted)
        button.titleLabel?.font = configuration.textStyleFonts[.subheadline]?
                                        .limitingFontSize(to: Constants.maximumFontSize)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        button.isExclusiveTouch = true
        return button
    }()

    private var descriptionWidthConstraint: NSLayoutConstraint?
    private var descriptionWidthLandscapeConstraint: NSLayoutConstraint?

    private var contentView = UIView()

    private let configuration = GiniConfiguration.shared

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()

        // Configure view hierachy
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        addSubview(button)

        // Add constraints
        addConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let isLandscape = currentInterfaceOrientation.isLandscape
//        descriptionWidthConstraint?.isActive = !isLandscape
//        descriptionWidthLandscapeConstraint?.isActive = isLandscape
    }

    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func openSettings() {
        GiniAnalyticsManager.track(event: .giveAccessTapped, screenName: .cameraAccess)
        UIApplication.shared.openAppSettings()
    }

    // MARK: Constraints
    fileprivate func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        descriptionWidthConstraint = descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                             multiplier: Constants.widthCoefficient)
        descriptionWidthLandscapeConstraint = descriptionLabel.widthAnchor.constraint(equalToConstant: Constants.descriptionWidthIphoneLandscape)

        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor, constant: Constants.padding),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Constants.padding * 2),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            // Image view
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            // titleLabel
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding * 2),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                              multiplier: Constants.widthCoefficient),
            // descriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.padding),
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionWidthConstraint!,
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // button
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                           constant: -Constants.padding * 2),
            button.widthAnchor.constraint(greaterThanOrEqualTo: descriptionLabel.widthAnchor),
            button.heightAnchor.constraint(equalToConstant: Constants.padding * 4),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.padding),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)])
    }
}

extension CameraNotAuthorizedView {
    private enum Constants {
        static let padding: CGFloat = 16
        static let widthCoefficient: CGFloat = 0.7
        static let descriptionWidthIphoneLandscape: CGFloat = 276
        static let imageSize: CGSize = CGSize(width: 50, height: 50)
        static let maximumFontSize: CGFloat = 36
    }
}
