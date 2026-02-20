//
//  CustomOnboardingBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 27/10/2022.
//

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
        // Intentionally left empty - no implementation needed
    }
    
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        // Intentionally left empty - no implementation needed
    }
    
    @objc func actionPressed() {
        buttonClicked?()
    }
    
    func injectedView() -> UIView {
		guard let view =  CustomOnboardingBottomNavigationBar().loadNib() as? CustomOnboardingBottomNavigationBar else {
			return UIView()
		}
		view.nextButton.addTarget(self,
								  action: #selector(actionPressed),
								  for: .touchUpInside)
		return view
	}
    
    func onDeinit() {
        buttonClicked = nil
    }
}
