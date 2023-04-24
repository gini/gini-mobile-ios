//
//  DefaultHelpBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 04/10/2022.
//

import UIKit

final class DefaultHelpBottomNavigationBarAdapter: HelpBottomNavigationBarAdapter {
    private var backButtonCallback: (() -> Void)?

    // Add the callback whenever the back button is clicked
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
        if let navigationBarView = BackButtonBottomNavigationBar().loadNib() as? BackButtonBottomNavigationBar {
            navigationBarView.backButton.addAction(self, #selector(backButtonClicked))
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
