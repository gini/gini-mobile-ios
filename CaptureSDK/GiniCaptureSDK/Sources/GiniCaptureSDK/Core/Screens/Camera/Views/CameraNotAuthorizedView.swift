//
//  CameraNotAuthorizedView.swift
//  GiniCapture
//
//  Created by Peter Pult on 06/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraNotAuthorizedView: UIView {
    // User interface
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredFormat("ginicapture.camera.notAuthorized.title",
                                                          comment: "Not authorized title")
        label.numberOfLines = 0
        label.textColor = GiniColor(light: UIColor.GiniCapture.dark1, dark: UIColor.GiniCapture.light1).uiColor()
        label.textAlignment = .center
        label.font = configuration.textStyleFonts[.title2]
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredFormat("ginicapture.camera.notAuthorized.description",
                                                          comment: "Not authorized description")
        label.numberOfLines = 0
        label.textColor = UIColor.GiniCapture.dark7
        label.textAlignment = .center
        label.font = configuration.textStyleFonts[.headline]
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamedPreferred(named: "cameraNotAuthorizedIcon")
        imageView.contentMode = .scaleAspectFit
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
        button.titleLabel?.font = configuration.textStyleFonts[.subheadline]
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        return button
    }()

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

    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func openSettings() {
        UIApplication.shared.openAppSettings()
    }

    // MARK: Constraints
    fileprivate func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constants.padding * 2),
            contentView.bottomAnchor.constraint(equalTo: centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
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
            descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                    multiplier: Constants.widthCoefficient),
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
        static let imageSize: CGSize = CGSize(width: 50, height: 50)
    }
}
