//
//  CameraBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 26/09/2022.
//

import UIKit

public enum CameraNavigationBarBottomButton {
    case back
    case help
}

class DefaultCameraBottomNavigationBarAdapter: CameraBottomNavigationBarAdapter {

    private var helpButtonCallback: (() -> Void)?
    private var backButtonCallback: (() -> Void)?

    func showButtons(navigationBar: UIView, navigationButtons: [CameraNavigationBarBottomButton]) {
        if let navigationView = navigationBar as? CameraBottomNavigationBar {
            if navigationButtons.contains(.help) {
                navigationView.rightButtonContainer.isHidden = false
            } else {
                navigationView.rightButtonContainer.isHidden = true
            }
            if navigationButtons.contains(.back) {
                navigationView.leftButtonContainer.isHidden = false
            } else {
                navigationView.leftButtonContainer.isHidden = true
            }
        }
    }

    // Add the callback whenever the help button is clicked
    func setHelpButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        helpButtonCallback = callback
    }

    // Add the callback whenever the back button is clicked
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
        if let navigationBarView =
            CameraBottomNavigationBar().loadNib() as?
            CameraBottomNavigationBar {
            navigationBarView.rightBarButton.addAction(self, #selector(helpButtonClicked))
            navigationBarView.leftBarButton.addAction(self, #selector(backButtonClicked))
            return navigationBarView
        }
        return UIView()
    }

    @objc func helpButtonClicked() {
        helpButtonCallback?()
    }

    @objc func backButtonClicked() {
        backButtonCallback?()
    }

    func onDeinit() {
        helpButtonCallback = nil
        backButtonCallback = nil
    }
}
