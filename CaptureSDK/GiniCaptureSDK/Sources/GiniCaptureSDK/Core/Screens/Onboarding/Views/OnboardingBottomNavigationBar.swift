//
//  OnboardingBottomNavigationBar.swift
//  
//
//  Created by Nadya Karaban on 23.05.22.
//

import Foundation
import UIKit

final class OnboardingBottomNavigationBar: UIView {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var getStarted: UIButton!
    private let cornerRadius: CGFloat = 16

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        backgroundColor = GiniColor(
            light: UIColor.GiniCapture.dark2,
            dark: UIColor.GiniCapture.dark2
        ).uiColor()
        skipButton.backgroundColor = GiniColor(light: UIColor.clear, dark: UIColor.clear).uiColor()
        skipButton.setTitleColor(
            GiniColor(
                light: UIColor.GiniCapture.accent1,
                dark: UIColor.GiniCapture.accent1
            ).uiColor(),
            for: .normal)
        nextButton.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.accent1,
            dark: UIColor.GiniCapture.accent1
        ).uiColor()
        nextButton.setTitleColor(
            GiniColor(
                light: UIColor.GiniCapture.labelWhite,
                dark: UIColor.GiniCapture.labelWhite
            ).uiColor(), for: .normal)
        getStarted.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.accent1,
            dark: UIColor.GiniCapture.accent1
        ).uiColor()
        getStarted.setTitleColor(
            GiniColor(
                light: UIColor.GiniCapture.labelWhite,
                dark: UIColor.GiniCapture.labelWhite
            ).uiColor(), for: .normal)
        skipButton.layer.cornerRadius = cornerRadius
        nextButton.layer.cornerRadius = cornerRadius
        getStarted.layer.cornerRadius = cornerRadius
    }
}
