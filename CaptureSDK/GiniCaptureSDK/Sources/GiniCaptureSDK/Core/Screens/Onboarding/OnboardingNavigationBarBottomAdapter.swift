//
//  OnboardingNavigationBarBottomAdapter.swift
//  
//
//  Created by Nadya Karaban on 08.08.22.
//

import Foundation
import UIKit

/**
Protocol that Gini Bank SDK uses to allow custom view for bottom navigation Bar.

- note: Bottom navigation only.
*/
public protocol OnboardingNavigationBarBottomAdapter: InjectedViewAdapter {
    
    func showButtons(navigationButtons: [OnboardingNavigationBarBottomButton])
    /**
     *  Sets the callback on next button action
     *
     * - Parameter callback:          An  action callback, which should be retained and called in next button action method
     */
    func setNextButtonClickedActionCallback(_ callback: @escaping () -> Void)
    
    /**
     *  Sets the callback on skip button action
     *
     * - Parameter callback:          An  action callback, which should be retained and called in skip button action method
     */
    func setSkipButtonClickedActionCallback(_ callback: @escaping () -> Void)
    
    /**
     *  Sets the callback on get started button action
     *
     * - Parameter callback:          An  action callback, which should be retained and called in get started button action method
     */
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping  () -> Void)
}

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
    
    func onDeinit() {
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
