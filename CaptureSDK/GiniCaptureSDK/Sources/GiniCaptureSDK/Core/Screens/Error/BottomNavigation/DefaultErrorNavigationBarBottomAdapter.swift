//
//  DefaultErrorNavigationBarBottomAdapter.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class DefaultErrorNavigationBarBottomAdapter: ErrorNavigationBarBottomAdapter {
    private var backButtonCallback: (() -> Void)?

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
        let navigationBar = DefaultErrorNavigationBottomBar()
        navigationBar.backButton.addAction(self, #selector(backButtonClicked))
        return navigationBar
    }

    @objc private func backButtonClicked() {
        backButtonCallback?()
    }

    func onDeinit() {
        backButtonCallback = nil
    }
}
