//
//  CustomOnboardingBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 27/10/2022.
//

import Foundation
import GiniCaptureSDK
import UIKit

class CustomOnboardingBottomNavigationBarAdapter: OnboardingNavigationBarBottomAdapter {
    private var buttonClicked: (() -> Void)?
    
    func showButtons(
        navigationButtons: [GiniCaptureSDK.OnboardingNavigationBarBottomButton],
        navigationBar: UIView) {
            if let customBar = navigationBar as? CustomOnboardingBottomNavigationBar {
                if navigationButtons.count > 0 {
                    customBar.nextButton.isHidden = false
                }
            }
    }
    
    func setNextButtonClickedActionCallback(_ callback: @escaping () -> Void) {
            buttonClicked = callback
    }
    
    func setSkipButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        
    }
    
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        
    }
    
    @objc func actionPressed() {
        buttonClicked?()
    }
    
    func injectedView() -> UIView {
        if let view =  CustomOnboardingBottomNavigationBar().loadNib() as? CustomOnboardingBottomNavigationBar {
            view.nextButton.addTarget(
                self,
                action: #selector(actionPressed),
                for: .touchUpInside)
            return view
        }
        return UIView()
    }
    
    func onDeinit() {
        buttonClicked = nil
    }
    
    
}
