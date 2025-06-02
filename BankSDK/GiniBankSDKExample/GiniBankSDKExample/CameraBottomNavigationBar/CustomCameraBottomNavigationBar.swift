//
//  CustomCameraBottomNavigationBar.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 10/11/2022.
//

import UIKit

class CustomCameraBottomNavigationBar: UIView {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    lazy var heightConstraint = heightAnchor.constraint(equalToConstant: Constants.heightPortrait)

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.gray
        heightConstraint.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint.constant = currentInterfaceOrientation.isLandscape ? Constants.heightLandscape : Constants.heightPortrait
    }
}

extension CustomCameraBottomNavigationBar {
    enum Constants {
        static let heightPortrait: CGFloat = 114
        static let heightLandscape: CGFloat = UIDevice.current.isSmallIphone ? 40 : 62
    }
}
