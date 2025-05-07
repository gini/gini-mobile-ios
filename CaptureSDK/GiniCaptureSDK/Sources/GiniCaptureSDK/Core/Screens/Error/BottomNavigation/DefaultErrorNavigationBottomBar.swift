//
//  DefaultErrorNavigationBottomBar.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class DefaultErrorNavigationBottomBar: UIView {
    let backButton = GiniBarButton(ofType: .back(title: ""))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backButton.buttonView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton.buttonView)
        NSLayoutConstraint.activate([
            backButton.buttonView.topAnchor.constraint(equalTo: topAnchor),
            backButton.buttonView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                           constant: Constants.horizontalPadding),
            backButton.buttonView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            backButton.buttonView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark1).uiColor()
    }

    private enum Constants {
        static let horizontalPadding: CGFloat = 8
    }
}
