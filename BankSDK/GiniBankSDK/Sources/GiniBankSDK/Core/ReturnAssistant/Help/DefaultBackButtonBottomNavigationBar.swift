//
//  DefaultBackButtonBottomNavigationBar.swift
//  
//
//  Created by Krzysztof Kryniecki on 04/10/2022.
//

import UIKit
import GiniCaptureSDK

/**
A custom view that displays a back button on the bottom navigation bar.

This class is a subclass of UIView.
*/

final class DefaultBackButtonBottomNavigationBar: UIView {

    @IBOutlet weak var backButtonContainerView: UIView!
    let backButton = GiniBarButton(ofType: .back(title: "    "))

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        backButton.buttonView.translatesAutoresizingMaskIntoConstraints = false
        backButtonContainerView.addSubview(backButton.buttonView)
        NSLayoutConstraint.activate([
            backButton.buttonView.topAnchor.constraint(equalTo: backButtonContainerView.topAnchor),
            backButton.buttonView.leadingAnchor.constraint(equalTo: backButtonContainerView.leadingAnchor),
            backButton.buttonView.trailingAnchor.constraint(equalTo: backButtonContainerView.trailingAnchor),
            backButton.buttonView.bottomAnchor.constraint(equalTo: backButtonContainerView.bottomAnchor)
        ])
        backgroundColor = GiniColor(light: UIColor.GiniBank.light1, dark: UIColor.GiniBank.dark1).uiColor()
    }
}
