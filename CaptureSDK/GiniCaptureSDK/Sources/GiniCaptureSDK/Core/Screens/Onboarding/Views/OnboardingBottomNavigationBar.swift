//
//  OnboardingBottomNavigationBar.swift
//  
//
//  Created by Nadya Karaban on 23.05.22.
//

import Foundation
import UIKit

final class OnboardingBottomNavigationBar: UIView {

    @IBOutlet weak var nextButton: GiniCaptureButton!
    @IBOutlet weak var skipButton: GiniCaptureButton!
    @IBOutlet weak var getStarted: GiniCaptureButton!

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

        nextButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        nextButton.configure(with: configuration.primaryButtonConfiguration)
        nextButton.isAccessibilityElement = true
        nextButton.isExclusiveTouch = true

        skipButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        skipButton.configure(with: configuration.transparentButtonConfiguration)
        skipButton.isAccessibilityElement = true
        skipButton.isExclusiveTouch = true

        getStarted.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        getStarted.configure(with: configuration.primaryButtonConfiguration)
        getStarted.isAccessibilityElement = true
        getStarted.isExclusiveTouch = true

        skipButton.setTitle(NSLocalizedStringPreferredFormat("ginicapture.onboarding.skip",
                                                             comment: "Skip button"), for: .normal)
        skipButton.accessibilityValue = NSLocalizedStringPreferredFormat("ginicapture.onboarding.skip",
                                                                         comment: "Skip button")

        nextButton.setTitle(NSLocalizedStringPreferredFormat("ginicapture.onboarding.next",
                                                             comment: "Next button"), for: .normal)
        nextButton.accessibilityValue = NSLocalizedStringPreferredFormat("ginicapture.onboarding.next",
                                                                         comment: "Next button")

        getStarted.setTitle(NSLocalizedStringPreferredFormat("ginicapture.onboarding.getstarted",
                                                             comment: "Get Started button"), for: .normal)
        getStarted.accessibilityValue = NSLocalizedStringPreferredFormat("ginicapture.onboarding.getstarted",
                                                                         comment: "Get Started button")
    }
}
