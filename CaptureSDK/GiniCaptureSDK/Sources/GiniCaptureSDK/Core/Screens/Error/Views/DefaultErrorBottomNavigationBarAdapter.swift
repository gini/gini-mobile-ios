//
//  DefaultErrorBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 29/11/2022.
//

import Foundation
import UIKit

class DefaultErrorBottomNavigationBarAdapter: ErrorBottomNavigationBarAdapter {

    private var backButtonCallback: (() -> Void)?

    // Add the callback whenever the back button is clicked
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
        if let navigationBarView =
            BackButtonBottomNavigationBar().loadNib() as? BackButtonBottomNavigationBar {
            navigationBarView.backButton.addTarget(
                self,
                action: #selector(backButtonClicked),
                for: .touchUpInside)
            return navigationBarView
        }
        return UIView()
    }

    @objc func backButtonClicked() {
        backButtonCallback?()
    }

    func onDeinit() {
        backButtonCallback = nil
    }
}
