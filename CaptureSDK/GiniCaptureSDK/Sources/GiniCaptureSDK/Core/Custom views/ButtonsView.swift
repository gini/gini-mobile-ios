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
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.setTitle(firstButtonTitle,
                             for: .normal)
        return button
    }()

    lazy var retakeButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        //
        button.setTitle(secondButtonTitle,
                              for: .normal)
        return button
    }()

    lazy var buttonsView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(enterButton)
        stackView.addArrangedSubview(retakeButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    let firstButtonTitle: String
    let secondButtonTitle: String

    init(firstTitle: String, secondTitle: String) {
        firstButtonTitle = firstTitle
        secondButtonTitle = secondTitle
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

    private func configureButtonsColors() {
        retakeButton.setTitleColor(giniConfiguration.primaryButtonTitleColor.uiColor(), for: .normal)
        retakeButton.backgroundColor = giniConfiguration.primaryButtonBackgroundColor.uiColor()
        retakeButton.layer.borderColor = giniConfiguration.primaryButtonBorderColor.uiColor().cgColor
        retakeButton.layer.cornerRadius = giniConfiguration.primaryButtonCornerRadius
        retakeButton.layer.borderWidth = giniConfiguration.primaryButtonBorderWidth
        retakeButton.layer.shadowRadius = giniConfiguration.primaryButtonShadowRadius
        retakeButton.layer.shadowColor = giniConfiguration.primaryButtonShadowColor.uiColor().cgColor

        enterButton.backgroundColor = giniConfiguration.outlineButtonBackground.uiColor()
        enterButton.layer.cornerRadius = giniConfiguration.outlineButtonCornerRadius
        enterButton.layer.borderWidth = giniConfiguration.outlineButtonBorderWidth
        enterButton.layer.borderColor = giniConfiguration.outlineButtonBorderColor.uiColor().cgColor
        enterButton.layer.shadowRadius = giniConfiguration.outlineButtonShadowRadius
        enterButton.layer.shadowColor = giniConfiguration.outlineButtonShadowColor.uiColor().cgColor
        enterButton.setTitleColor(giniConfiguration.outlineButtonTitleColor.uiColor(), for: .normal)
    }

    private func configureButtons() {
        configureButtonsColors()
        enterButton.addBlurEffect(cornerRadius: giniConfiguration.outlineButtonCornerRadius)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
