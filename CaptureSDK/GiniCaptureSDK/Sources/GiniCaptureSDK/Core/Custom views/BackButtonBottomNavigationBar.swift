//
//  BackButtonBottomNavigationBar.swift
//  
//
//  Created by Krzysztof Kryniecki on 04/10/2022.
//

import UIKit

public final class BackButtonBottomNavigationBar: UIView {

    @IBOutlet weak var backButton: UIButton!

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
<<<<<<< HEAD
            dark: UIColor.GiniCapture.dark2
=======
            dark: UIColor.GiniCapture.dark1
>>>>>>> 4e7ab34ef5bb18965a5bc97609110a2c840551ec
        ).uiColor()
    }
}
