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
        backgroundColor = GiniColor(light: .GiniCapture.light1, dark: .GiniCapture.dark1).uiColor()
        skipButton.backgroundColor = .clear
        skipButton.setTitleColor(GiniColor(light: .GiniCapture.accent1, dark: .GiniCapture.accent1).uiColor(),
                                 for: .normal)
        nextButton.backgroundColor = GiniColor(light: .GiniCapture.accent1, dark: .GiniCapture.accent1).uiColor()
        nextButton.setTitleColor(GiniColor(light: .GiniCapture.labelWhite, dark: .GiniCapture.labelWhite).uiColor(),
                                 for: .normal)
        getStarted.backgroundColor = GiniColor(light: .GiniCapture.accent1, dark: .GiniCapture.accent1).uiColor()
        getStarted.setTitleColor(GiniColor(light: .GiniCapture.labelWhite, dark: .GiniCapture.labelWhite).uiColor(),
                                 for: .normal)
        skipButton.layer.cornerRadius = cornerRadius
        nextButton.layer.cornerRadius = cornerRadius
        getStarted.layer.cornerRadius = cornerRadius
        setupButtons()
    }

    private func setupButtons() {
        skipButton.setTitle(NSLocalizedStringPreferredFormat(
            "ginicapture.onboarding.skip",
            comment: "Skip button"), for: .normal)
        nextButton.setTitle(NSLocalizedStringPreferredFormat(
            "ginicapture.onboarding.next",
            comment: "Next button"), for: .normal)
        getStarted.setTitle(NSLocalizedStringPreferredFormat(
            "ginicapture.onboarding.getstarted",
            comment: "Get Started button"), for: .normal)
    }
}
