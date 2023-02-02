//
//  CameraBottomNavigationBar.swift
//  
//
//  Created by Krzysztof Kryniecki on 26/09/2022.
//

import UIKit

class CameraBottomNavigationBar: UIView {

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        let configuration = GiniConfiguration.shared
        let textColor = UIColor.GiniCapture.accent1
        let font = configuration.textStyleFonts[.body] ?? UIFont.systemFont(ofSize: 20)
        let rightButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.camera.help",
                                                                comment: "Camera Help Button")
        let rightAttributedString = NSAttributedString(string: rightButtonTitle,
                                                       attributes: [NSAttributedString.Key.font: font,
                                                                    NSAttributedString.Key.foregroundColor: textColor])
        rightButton.setAttributedTitle(rightAttributedString, for: .normal)
        rightButton.tintColor = GiniColor(light: UIColor.GiniCapture.dark1, dark: UIColor.GiniCapture.light1).uiColor()

        let leftButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.analysis.backToReview",
                                                               comment: "Review screen title")
        let leftAttributedString = NSAttributedString(string: leftButtonTitle,
                                                      attributes: [NSAttributedString.Key.font: font,
                                                                   NSAttributedString.Key.foregroundColor: textColor])
        leftButton.setAttributedTitle(leftAttributedString, for: .normal)

        if #available(iOS 15.0, *) {
            leftButton.configuration?.imagePadding = 4
        } else {
            leftButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        }

        leftButton.setImage(
            UIImageNamedPreferred(named: "arrowBack")?.tintedImageWithColor(textColor) ?? UIImage(),
            for: .normal)
        backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark1).uiColor()
    }
}
