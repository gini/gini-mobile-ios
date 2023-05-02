//
//  BackButtonBottomNavigationBar.swift
//  
//
//  Created by Krzysztof Kryniecki on 04/10/2022.
//

import UIKit

/**
A custom view that displays a back button on the bottom navigation bar.

This class is a subclass of UIView.
*/

final class BackButtonBottomNavigationBar: UIView {

    /// The button that displays the back arrow icon.
    @IBOutlet weak var backButtonContainer: UIView!
    let backButton = GiniBarButton(ofType: .back(title: "    "))

    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        backgroundColor = GiniColor(light: .GiniCapture.light1, dark: .GiniCapture.dark1).uiColor()
        backButton.buttonView.fixInView(backButtonContainer)
    }
}
