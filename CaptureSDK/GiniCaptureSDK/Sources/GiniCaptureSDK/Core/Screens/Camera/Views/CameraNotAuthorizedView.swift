//
//  CameraNotAuthorizedView.swift
//  GiniCapture
//
//  Created by Peter Pult on 06/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

final class CameraNotAuthorizedView: UIView {

    // User interface
    fileprivate var label = UILabel()
    fileprivate var button = UIButton()
    fileprivate var imageView = UIImageView()
    fileprivate var contentView = UIView()

    // Images
    fileprivate var noCameraImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraNotAuthorizedIcon")
    }

    init(giniConfiguration: GiniConfiguration = GiniConfiguration.shared) {
        super.init(frame: CGRect.zero)
        // Configure image view
        imageView.image = noCameraImage
        imageView.contentMode = .scaleAspectFit

        // Configure label
        label.text = NSLocalizedStringPreferredFormat(
            "ginicapture.camera.notAuthorized",
            comment: "Not authorized text")
        label.numberOfLines = 0
        label.textColor = giniConfiguration.cameraNotAuthorizedTextColor.uiColor()
        label.textAlignment = .center
        label.font = giniConfiguration.textStyleFonts[.title2]

        // Configure button
        button.setTitle(
            NSLocalizedStringPreferredFormat(
                "ginicapture.camera.notAuthorizedButton", comment: "Grant permission"),
            for: .normal)
        button.setTitleColor(giniConfiguration.cameraNotAuthorizedButtonTitleColor.uiColor(), for: .normal)
        button.setTitleColor(giniConfiguration.cameraNotAuthorizedButtonTitleColor.uiColor().withAlphaComponent(0.8),
                             for: .highlighted)
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.subheadline]

        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        // Configure view hierachy
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(button)

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

    @IBAction func openSettings(_ sender: AnyObject) {
        UIApplication.shared.openAppSettings()
    }

    // MARK: Constraints
    fileprivate func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 30),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            // Image view
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 204),
            imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),
            imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 75),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            // label
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            // button
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualTo: label.widthAnchor),
            button.heightAnchor.constraint(equalToConstant: 35),
            button.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: 4),
            button.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: 4),
            button.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

}
