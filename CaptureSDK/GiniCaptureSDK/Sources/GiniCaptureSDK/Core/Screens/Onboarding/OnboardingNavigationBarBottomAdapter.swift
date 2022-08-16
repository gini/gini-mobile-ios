//
//  File.swift
//  
//
//  Created by Nadya Karaban on 08.08.22.
//

import Foundation
import UIKit

public protocol OnboardingNavigationBarBottomAdapter : InjectedViewAdapter {
    func didClickSkipButton()
    func didClickNextButton()
    func didClickGetStartedButton()
    func showButtons(navigationButtons:[OnboardingNavigationBarBottomButton])
}

public enum OnboardingNavigationBarBottomButton: Int {
    case SKIP
    case NEXT
    case GET_STARTED
}

class DefaultOnboardingNavigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter {
    func injectedView() -> UIView {
        return UIView()
    }
    
    func didClickSkipButton() {
        
    }
    
    func didClickNextButton() {
        
    }
    
    func didClickGetStartedButton() {
        
    }
    
    func showButtons(navigationButtons: [OnboardingNavigationBarBottomButton]) {
        
    }
    
    
}
