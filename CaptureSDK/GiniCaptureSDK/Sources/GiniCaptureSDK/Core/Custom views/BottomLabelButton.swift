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
        button.isExclusiveTouch = true
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

    private lazy var contentView: UIStackView = {
        let contentView = UIStackView(arrangedSubviews: [iconView, actionLabel])
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.spacing = 5
        contentView.axis = .vertical
        return contentView
    }()

    init() {
        super.init(frame: .zero)
        addSubview(contentView)
        contentView.addSubview(actionLabel)
        contentView.addSubview(iconView)
        addSubview(actionButton)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        addSubview(contentView)
        contentView.addSubview(actionLabel)
        contentView.addSubview(iconView)
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

            contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 5),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),

            iconView.heightAnchor.constraint(equalToConstant: 20),
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
