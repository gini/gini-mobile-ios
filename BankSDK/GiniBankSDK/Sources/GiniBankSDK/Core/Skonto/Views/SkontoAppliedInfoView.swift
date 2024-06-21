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
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}
