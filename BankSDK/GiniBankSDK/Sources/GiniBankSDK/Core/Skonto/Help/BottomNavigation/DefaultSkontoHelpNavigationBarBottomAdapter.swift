//
//  DefaultSkontoHelpNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class DefaultSkontoHelpNavigationBarBottomAdapter: SkontoHelpNavigationBarBottomAdapter {
    private var backButtonCallback: (() -> Void)?

    // Add the callback whenever the back button is clicked
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func injectedView() -> UIView {
        let navigationBarView = DefaultSkontoHelpNavigationBottomBar()
        navigationBarView.backButton.addAction(self, #selector(backButtonClicked))
        return navigationBarView
    }

    @objc func backButtonClicked() {
        backButtonCallback?()
    }

    func onDeinit() {
        backButtonCallback = nil
    }
}
