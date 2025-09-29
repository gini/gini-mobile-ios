//
//  CustomCameraBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class CustomCameraBottomNavigationBarAdapter: CameraBottomNavigationBarAdapter {
    func showButtons(navigationBar: UIView, navigationButtons: [GiniCaptureSDK.CameraNavigationBarBottomButton]) {
        // This method will remain empty;   CustomCameraBottomNavigationBar provides its own buttons
    }
    
    func setHelpButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        helpButtonCallback = callback
    }
    
    private var backButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
		guard let navigationBarView = CustomCameraBottomNavigationBar().loadNib() as? CustomCameraBottomNavigationBar else {
			return UIView()
		}
		navigationBarView.backButton.addTarget(self,
											   action: #selector(backButtonClicked),
											   for: .touchUpInside)
		navigationBarView.helpButton.addTarget(self,
											   action: #selector(helpButtonClicked),
											   for: .touchUpInside)
		return navigationBarView
	}

    @objc func backButtonClicked() {
        backButtonCallback?()
    }
    
    @objc func helpButtonClicked() {
        helpButtonCallback?()
    }

    func onDeinit() {
        backButtonCallback = nil
    }
}
