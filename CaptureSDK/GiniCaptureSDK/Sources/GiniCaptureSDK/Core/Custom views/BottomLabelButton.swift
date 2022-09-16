//
//  BottomLabelButton.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

class BottomLabelButton: UIButton {
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
        label.textColor = .white
        label.minimumScaleFactor = 10 / label.font.pointSize
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var iconView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    } ()
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        addSubview(actionLabel)
        addSubview(iconView)
        addSubview(actionButton)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
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
            
        ])
    }
    
    func configureButton(
        image: UIImage,
        name: String) {
        iconView.image = image
        actionLabel.text = name
    }
    
    @objc fileprivate func didPressButton(_ sender: UIButton) {
        didTapButton?()
    }
}
