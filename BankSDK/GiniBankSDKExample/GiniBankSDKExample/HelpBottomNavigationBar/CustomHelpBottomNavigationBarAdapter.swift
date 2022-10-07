//
//  CustomHelpBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 07/10/2022.
//

import UIKit
import GiniCaptureSDK

final class CustomHelpBottomNavigationBarAdapter: HelpBottomNavigationBarAdapter {
    private var backButtonCallback: (() -> Void)?

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    private func loadNib() -> UIView {
        return Bundle(for: CustomHelpBottomNavigationBar.self).loadNibNamed(String(describing: CustomHelpBottomNavigationBar.self), owner: nil, options: nil)![0] as! CustomHelpBottomNavigationBar
    }
    
    func injectedView() -> UIView {
        if let navigationBarView = loadNib() as? CustomHelpBottomNavigationBar {
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
