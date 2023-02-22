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
    @IBOutlet public weak var backButton: UIButton!

    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        backButton.setTitle("", for: .normal)
        let image = UIImageNamedPreferred(named: "arrowBack") ?? UIImage()
        backButton.setImage(
            image.tintedImageWithColor(.GiniCapture.accent1),
            for: .normal)
        backgroundColor = GiniColor(
            light: UIColor.GiniCapture.light1,
            dark: UIColor.GiniCapture.dark1
        ).uiColor()
    }
}
