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
        button.setTitle(firstButtonTitle, for: .normal)
        button.accessibilityLabel = firstButtonTitle
        return button
    }()

    lazy var retakeButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(secondButtonTitle, for: .normal)
        button.accessibilityLabel = secondButtonTitle
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

    var axis: NSLayoutConstraint.Axis {
        get { buttonsView.axis }
        set { buttonsView.axis = newValue }
    }

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
