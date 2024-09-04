//
//  DefaultSkontoHelpNavigationBottomBar.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

/**
 A custom view that displays a back button on the Skonto bottom navigation bar.
*/

final class DefaultSkontoHelpNavigationBottomBar: UIView {
    let backButton = GiniBarButton(ofType: .back(title: ""))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        backButton.buttonView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton.buttonView)
        NSLayoutConstraint.activate([
            backButton.buttonView.topAnchor.constraint(equalTo: topAnchor),
            backButton.buttonView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                           constant: Constants.horizontalPadding),
            backButton.buttonView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            backButton.buttonView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        backgroundColor = GiniColor(light: UIColor.GiniBank.light1, dark: UIColor.GiniBank.dark1).uiColor()
    }
}

private extension DefaultSkontoHelpNavigationBottomBar {
    enum Constants {
        static let horizontalPadding: CGFloat = 8
    }
}
