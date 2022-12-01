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

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        backgroundColor = GiniColor(light: .GiniCapture.light1, dark: .GiniCapture.dark1).uiColor()
        setupButtons()
    }

    private func setupButtons() {
        let configuration = GiniConfiguration.shared
        nextButton.configure(with: configuration.primaryButtonConfiguration)
        skipButton.configure(with: configuration.transparentButtonConfiguration)
        getStarted.configure(with: configuration.primaryButtonConfiguration)

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
