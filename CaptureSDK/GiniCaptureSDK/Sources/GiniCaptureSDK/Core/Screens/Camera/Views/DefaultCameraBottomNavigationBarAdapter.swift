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
    var view: CameraBottomNavigationBar?

    func showButtons(navigationButtons: [CameraNavigationBarBottomButton]) {
        if let navigationView = injectedView() as? CameraBottomNavigationBar {
            if navigationButtons.contains(.help) {
                navigationView.rightButton.isHidden = false
            } else {
                navigationView.rightButton.isHidden = true
            }
            if navigationButtons.contains(.back) {
                navigationView.leftButton.isHidden = false
            } else {
                navigationView.leftButton.isHidden = true
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
        if let navigationBarView = view {
            return navigationBarView
        } else {
            if let navigationBarView =
                CameraBottomNavigationBar().loadNib() as?
                CameraBottomNavigationBar {
                navigationBarView.rightButton.addTarget(
                    self,
                    action: #selector(helpButtonClicked),
                    for: .touchUpInside)
                navigationBarView.leftButton.addTarget(
                    self,
                    action: #selector(backButtonClicked),
                    for: .touchUpInside)
                view = navigationBarView
                return navigationBarView
            } else {
                return UIView()
            }
        }
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
