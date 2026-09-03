//
//  DefaultDigitalInvoiceSkontoNavigationBottomBar.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

/**
 A custom view that displays a Digital Invoice screen with Skonto information bottom navigation bar.
*/

final class DefaultDigitalInvoiceSkontoNavigationBottomBar: UIView {
    let backButton = GiniBarButton(ofType: .back(title: ""))
    let helpButton = GiniBarButton(ofType: .help)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        backButton.buttonView.translatesAutoresizingMaskIntoConstraints = false
        helpButton.buttonView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backButton.buttonView)
        addSubview(helpButton.buttonView)

        NSLayoutConstraint.activate([
            backButton.buttonView.topAnchor.constraint(equalTo: topAnchor),
            backButton.buttonView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                           constant: Constants.horizontalPadding),
            backButton.buttonView.trailingAnchor.constraint(lessThanOrEqualTo: helpButton.buttonView.leadingAnchor),
            backButton.buttonView.bottomAnchor.constraint(equalTo: bottomAnchor),

            helpButton.buttonView.topAnchor.constraint(equalTo: topAnchor),
            helpButton.buttonView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                           constant: -Constants.horizontalPadding),
            helpButton.buttonView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        backgroundColor = GiniColor(light: UIColor.GiniBank.light1, dark: UIColor.GiniBank.dark1).uiColor()
    }
}

private extension DefaultDigitalInvoiceSkontoNavigationBottomBar {
    enum Constants {
        static let horizontalPadding: CGFloat = 8
    }
}
