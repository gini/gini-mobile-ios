//
//  CustomHelpBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 07/10/2022.
//

import UIKit
import GiniCaptureSDK

final class CustomBottomNavigationBarAdapter: NoResultBottomNavigationBarAdapter, HelpBottomNavigationBarAdapter, ImagePickerBottomNavigationBarAdapter {
    private var backButtonCallback: (() -> Void)?

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
        if let navigationBarView = CustomBottomNavigationBar().loadNib() as? CustomBottomNavigationBar {
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
