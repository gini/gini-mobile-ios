//
//  DefaultDigitalInvoiceSkontoNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class DefaultDigitalInvoiceSkontoNavigationBarBottomAdapter: DigitalInvoiceSkontoNavigationBarBottomAdapter {
    private var backButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?

    // Add the callback whenever the back button is clicked
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func setHelpButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        helpButtonCallback = callback
    }

    func injectedView() -> UIView {
        let navigationBarView = DefaultDigitalInvoiceSkontoNavigationBottomBar()
        navigationBarView.backButton.addAction(self, #selector(backButtonClicked))
        navigationBarView.helpButton.addAction(self, #selector(helpButtonClicked))
        return navigationBarView
    }

    @objc func backButtonClicked() {
        backButtonCallback?()
    }

    @objc func helpButtonClicked() {
        helpButtonCallback?()
    }

    func onDeinit() {
        backButtonCallback = nil
    }
}
