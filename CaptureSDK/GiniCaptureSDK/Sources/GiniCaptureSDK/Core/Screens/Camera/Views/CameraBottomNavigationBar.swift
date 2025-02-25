//
//  CameraBottomNavigationBar.swift
//  
//
//  Created by Krzysztof Kryniecki on 26/09/2022.
//

import UIKit

class CameraBottomNavigationBar: UIView {

    @IBOutlet weak var leftButtonContainer: UIView!
    @IBOutlet weak var rightButtonContainer: UIView!

    private let leftButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.analysis.backToReview",
                                                                   comment: "Review")
    lazy var leftBarButton = GiniBarButton(ofType: .back(title: leftButtonTitle))
    lazy var rightBarButton = GiniBarButton(ofType: .help)
    lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 114)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint.constant = currentInterfaceOrientation.isLandscape ? 62 : 114
    }

    func setupView() {
        leftBarButton.buttonView.fixInView(leftButtonContainer)
        rightBarButton.buttonView.fixInView(rightButtonContainer)

        backgroundColor = GiniColor(light: .GiniCapture.light1, dark: .GiniCapture.dark1).uiColor()

        heightConstraint.isActive = true
    }
}
