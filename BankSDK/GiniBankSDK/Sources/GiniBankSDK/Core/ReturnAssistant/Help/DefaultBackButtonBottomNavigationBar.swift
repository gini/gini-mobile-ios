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

    /// The button that displays the back arrow icon.
    @IBOutlet weak var backButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        backButton.setTitle("", for: .normal)
        let image = UIImageNamedPreferred(named: "arrowBack") ?? UIImage()
        backButton.setImage(image.tintedImageWithColor(.GiniBank.accent1), for: .normal)
        backgroundColor = GiniColor(light: UIColor.GiniBank.light1, dark: UIColor.GiniBank.dark1).uiColor()
    }
}
