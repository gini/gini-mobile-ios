//
//  CustomCameraBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 10/11/2022.
//

import UIKit
import GiniCaptureSDK

final class CustomCameraBottomNavigationBarAdapter: CameraBottomNavigationBarAdapter {
    func showButtons(navigationBar: UIView, navigationButtons: [GiniCaptureSDK.CameraNavigationBarBottomButton]) {
        
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
        if let navigationBarView = CustomCameraBottomNavigationBar().loadNib() as? CustomCameraBottomNavigationBar {
            navigationBarView.backButton.addTarget(
                self,
                action: #selector(backButtonClicked),
                for: .touchUpInside)
            navigationBarView.helpButton.addTarget(
                self,
                action: #selector(helpButtonClicked),
                for: .touchUpInside)
            return navigationBarView
        } else {
            return UIView()
        }
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
