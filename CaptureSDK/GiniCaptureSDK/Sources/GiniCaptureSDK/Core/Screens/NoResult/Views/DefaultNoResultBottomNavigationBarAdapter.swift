//
//  DefaultNoResultBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/10/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class DefaultNoResultBottomNavigationBarAdapter: NoResultBottomNavigationBarAdapter {
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
