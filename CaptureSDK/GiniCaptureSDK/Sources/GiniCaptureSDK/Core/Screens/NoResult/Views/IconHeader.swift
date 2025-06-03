//
//  NoResultHeader.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

final class IconHeader: UIView {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = GiniConfiguration.shared.textStyleFonts[.subheadline]
        label.textColor = GiniColor(light: UIColor.GiniCapture.dark1, dark: UIColor.GiniCapture.light1).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var image: UIImage? {
        get {
            iconImageView.image
        }

        set {
            iconImageView.image = newValue
        }
    }

    var text: String? {
        get {
            headerLabel.text
        }

        set {
            headerLabel.text = newValue
        }
    }

    var iconAccessibilityLabel: String? {
        get {
            iconImageView.accessibilityLabel
        }

        set {
            iconImageView.accessibilityLabel = newValue
        }
    }

    fileprivate func configureAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [iconImageView, headerLabel]
        headerLabel.isAccessibilityElement = true
        iconImageView.isAccessibilityElement = true
        iconImageView.accessibilityTraits = .image
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        setupView()
        configureAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = GiniColor(light: UIColor.GiniCapture.error4, dark: UIColor.GiniCapture.error1).uiColor()
        addIconImageView()
        addHeaderLabel()
    }

    private func addIconImageView() {
        addSubview(iconImageView)

        NSLayoutConstraint.activate([iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                            constant: Constants.iconLeadingPadding),
                                     iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize.width),
                                     iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize.height)])
    }

    private func addHeaderLabel() {
        addSubview(headerLabel)

        NSLayoutConstraint.activate([headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     headerLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor,
                                                                          constant: Constants.headerLeadingPadding),
                                     headerLabel.topAnchor.constraint(equalTo: topAnchor,
                                                                      constant: Constants.headerTopBottomPadding),
                                     headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                         constant: -Constants.headerTopBottomPadding),
                                     headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                           constant: -Constants.headerTrailingPadding)])
    }

    private struct Constants {
        static let iconSize = CGSize(width: 24.0, height: 24.0)
        static let iconLeadingPadding = 35.0
        static let headerLeadingPadding: CGFloat = 19
        static let headerTopBottomPadding: CGFloat = 22
        static let headerTrailingPadding: CGFloat = 16
    }
}

/// This is to see in realtime the preview of the component to be built. This helps to not to have
/// to run the app with each change.
#if DEBUG
@available(iOS 17, *)
#Preview {
    let vc = UIViewController()

    let iconHeader = IconHeader(frame: .zero)

    vc.view.addSubview(iconHeader)
    NSLayoutConstraint.activate([
        iconHeader.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
        iconHeader.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
        iconHeader.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor)
    ])

    iconHeader.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt"

    iconHeader.image = UIImage(systemName: "person.circle")

    return vc
}
#endif
