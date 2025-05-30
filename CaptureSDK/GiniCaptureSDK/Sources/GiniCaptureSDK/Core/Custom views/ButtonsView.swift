//
//  ButtonsView.swift
//  
//
//  Created by Krzysztof Kryniecki on 21/11/2022.
//

import UIKit

class ButtonsView: UIView {
    private let giniConfiguration = GiniConfiguration.shared
    lazy var enterButton: MultilineTitleButton = configureStackViewButton(title: enterButtonTitle)
    lazy var retakeButton: MultilineTitleButton = configureStackViewButton(title: retakeButtonTitle)

    private func configureStackViewButton(title: String) -> MultilineTitleButton {
        let button = MultilineTitleButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = title
        return button
    }
    private lazy var buttonsView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(retakeButton)
        stackView.addArrangedSubview(enterButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private let enterButtonTitle: String
    private let retakeButtonTitle: String

    init(enterButtonTitle: String, retakeButtonTitle: String) {
        self.enterButtonTitle = enterButtonTitle
        self.retakeButtonTitle = retakeButtonTitle
        super.init(frame: CGRect.zero)
        addSubview(buttonsView)
        configureButtons()
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureButtons() {
        retakeButton.configure(with: giniConfiguration.primaryButtonConfiguration)
        enterButton.configure(with: giniConfiguration.secondaryButtonConfiguration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
