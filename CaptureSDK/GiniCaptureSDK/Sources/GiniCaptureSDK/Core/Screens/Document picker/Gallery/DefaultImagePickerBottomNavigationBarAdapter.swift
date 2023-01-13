//
//  DefaultImagePickerBottomNavigationBarAdapter.swift
//  
//
//  Created by David Vizaknai on 13.01.2023.
//

import UIKit

final class DefaultImagePickerBottomNavigationBarAdapter: ImagePickerBottomNavigationBarAdapter {
    private var backButtonCallback: (() -> Void)?

    // Add the callback whenever the back button is clicked
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
        if let navigationBarView = BackButtonBottomNavigationBar().loadNib() as? BackButtonBottomNavigationBar {
            navigationBarView.backButton.addTarget(
                self,
                action: #selector(backButtonClicked),
                for: .touchUpInside)
            return navigationBarView
        } else {
            return UIView()
        }
    }

    @objc func backButtonClicked() {
        backButtonCallback?()
    }

    func onDeinit() {
        backButtonCallback = nil
    }
}

