//
//  CustomHelpBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 07/10/2022.
//

import UIKit
import GiniCaptureSDK

final class CustomBottomNavigationBarAdapter: NoResultBottomNavigationBarAdapter, HelpBottomNavigationBarAdapter {
    private var backButtonCallback: (() -> Void)?

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    private func loadNib() -> UIView {
        return Bundle(for: CustomBottomNavigationBar.self).loadNibNamed(String(describing: CustomBottomNavigationBar.self), owner: nil, options: nil)![0] as! CustomBottomNavigationBar
    }
    
    func injectedView() -> UIView {
        if let navigationBarView = loadNib() as? CustomBottomNavigationBar {
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
