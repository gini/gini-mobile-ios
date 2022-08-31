//
//  File.swift
//  
//
//  Created by Nadya Karaban on 08.08.22.
//

import Foundation
import UIKit

//Option 1 Use blocks
public protocol OnboardingNavigationBarBottomAdapter: InjectedViewAdapter {
    
    func showButtons(navigationButtons: [OnboardingNavigationBarBottomButton])
    
    func setNextButtonClickedActionCallback(callback: @escaping () -> Void)
    func setSkipButtonClickedActionCallback(_ callback: @escaping () -> Void)
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping  () -> Void)
    
}

class DefaultOnboardingNavigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter {
    
    @objc func setNextButtonClickedActionCallback(callback: @escaping () -> Void) {
        nextButtonCallback = callback
    }
    
    private var nextButtonCallback: (() -> Void)?
    private var skipButtonCallback: (() -> Void)?
    private var getStartedButtonCallback: (() -> Void)?
    // Add the callback whenever the
    @objc func setSkipButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        skipButtonCallback = callback
    }
    
    @objc func setGetStartedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        getStartedButtonCallback = callback
    }
    
    func showButtons(navigationButtons: [OnboardingNavigationBarBottomButton]) {
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
            navigationBarView.getStarted.addTarget(self, action: #selector(getStartedButtonClicked), for: .touchUpInside)

            return navigationBarView
        } else {
            return UIView()
        }
    }
    
    func onDestroy() {
        nextButtonCallback = nil
        skipButtonCallback = nil
        getStartedButtonCallback = nil
    }
}

public enum OnboardingNavigationBarBottomButton: Int {
    case SKIP
    case NEXT
    case GET_STARTED
}
