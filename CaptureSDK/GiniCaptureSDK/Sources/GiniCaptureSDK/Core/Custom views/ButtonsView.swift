//
//  ButtonsView.swift
//  
//
//  Created by Krzysztof Kryniecki on 21/11/2022.
//

import UIKit

class ButtonsView: UIView {
    var giniConfiguration = GiniConfiguration.shared
    lazy var enterButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(enterButtonTitle, for: .normal)
        button.accessibilityLabel = enterButtonTitle
        return button
    }()

    lazy var retakeButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(retakeButtonTitle, for: .normal)
        button.accessibilityLabel = retakeButtonTitle
        return button
    }()

    lazy var buttonsView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(retakeButton)
        stackView.addArrangedSubview(enterButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    let enterButtonTitle: String
    let retakeButtonTitle: String

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
        retakeButton.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        retakeButton.configure(with: giniConfiguration.primaryButtonConfiguration)
        enterButton.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        enterButton.configure(with: giniConfiguration.secondaryButtonConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
