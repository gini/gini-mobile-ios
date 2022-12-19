//
//  BottomLabelButton.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class BottomLabelButton: UIView {
    var didTapButton: (() -> Void)?

    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        return button
    }()

    lazy var actionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.minimumScaleFactor = 2 / label.font.pointSize
        label.sizeToFit()
        return label
    }()

    lazy var iconView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    init() {
        super.init(frame: .zero)
        addSubview(actionLabel)
        addSubview(iconView)
        addSubview(actionButton)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        addSubview(actionLabel)
        addSubview(iconView)
        addSubview(actionButton)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement = true
        actionLabel.isAccessibilityElement = false
        actionButton.isAccessibilityElement = false
        iconView.isAccessibilityElement = false
        accessibilityTraits = .button
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor),

            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            actionLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 5),
            actionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0)
        ])
    }

    func setupButton(with image: UIImage, name: String) {
        iconView.image = image
        actionLabel.text = name
        accessibilityValue = name
    }

    @objc fileprivate func didPressButton(_ sender: UIButton) {
        didTapButton?()
    }
}
