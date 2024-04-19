//
//  DefaultOnboardingNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class DefaultOnboardingNavigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter {
    private var nextButtonCallback: (() -> Void)?
    private var skipButtonCallback: (() -> Void)?
    private var getStartedButtonCallback: (() -> Void)?

    // Add the callback whenever the next button is clicked
    @objc func setNextButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        nextButtonCallback = callback
    }

    // Add the callback whenever the skip button is clicked
    @objc func setSkipButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        skipButtonCallback = callback
    }

    // Add the callback whenever the get started button is clicked
    @objc func setGetStartedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        getStartedButtonCallback = callback
    }

    func showButtons(
        navigationButtons: [OnboardingNavigationBarBottomButton],
        navigationBar: UIView) {
            if let bar = navigationBar as? OnboardingBottomNavigationBar {
                bar.getStarted.isHidden = true
                bar.nextButton.isHidden = true
                bar.skipButton.isHidden = true
                for button in navigationButtons {
                    switch button {
                    case .getStarted:
                        bar.getStarted.isHidden = false
                    case .next:
                        bar.nextButton.isHidden = false
                    case .skip:
                        bar.skipButton.isHidden = false
                    }
                }
            }
    }

    @objc func nextButtonClicked() {
        nextButtonCallback?()
    }

    @objc func skipButtonClicked() {
        skipButtonCallback?()
    }

    @objc func getStartedButtonClicked() {
        getStartedButtonCallback?()
    }

    func injectedView() -> UIView {
        if let navigationBarView =
            OnboardingBottomNavigationBar().loadNib() as?
                OnboardingBottomNavigationBar {
            navigationBarView.nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
            navigationBarView.skipButton.addTarget(self, action: #selector(skipButtonClicked), for: .touchUpInside)
            navigationBarView.getStarted.addTarget(self, action: #selector(getStartedButtonClicked),
                                                   for: .touchUpInside)

            return navigationBarView
        } else {
            return UIView()
        }
    }

    func onDeinit() {
        nextButtonCallback = nil
        skipButtonCallback = nil
        getStartedButtonCallback = nil
    }
}
