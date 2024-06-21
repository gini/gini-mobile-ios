//
//  SkontoInfoMessageView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoAppliedInfoView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        // TODO: template image will be better
        imageView.image = GiniImages.icInfo.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.message",
                                                            comment: "Zahlung in 14 Tagen: 3% Skonto.")
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: text.count))
        label.attributedText = attributedString
        label.font = configuration.textStyleFonts[.caption1]
        label.textColor = GiniColor(light: .GiniBank.success2,
                                    dark: .GiniBank.success2).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let configuration = GiniBankConfiguration.shared

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = GiniColor(light: .GiniBank.success5,
                                    dark: .GiniBank.success5).uiColor()
        layer.cornerRadius = 8
        layer.masksToBounds = true
        addSubview(imageView)
        addSubview(label)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.imageVerticalPadding),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.imageVerticalPadding),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.imageHorizontalPadding),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.labelHorizontalPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.labelHorizontalPadding),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}

private extension SkontoAppliedInfoView {
    enum Constants {
        static let imageVerticalPadding: CGFloat = 10
        static let imageHorizontalPadding: CGFloat = 10
        static let imageSize: CGFloat = 24
        static let labelHorizontalPadding: CGFloat = 8
    }
}
