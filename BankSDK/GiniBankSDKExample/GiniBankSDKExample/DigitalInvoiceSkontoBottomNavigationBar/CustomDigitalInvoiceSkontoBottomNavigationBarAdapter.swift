//
//  CustomDigitalInvoiceSkontoBottomNavigationBarAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankSDK

class CustomDigitalInvoiceSkontoBottomNavigationBarAdapter: DigitalInvoiceSkontoNavigationBarBottomAdapter {
    private var view: CustomDigitalInvoiceSkontoBottomNavigationBar?
    private var backButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void) {
        helpButtonCallback = callback
    }

    func injectedView() -> UIView {
        let navigationBar = CustomDigitalInvoiceSkontoBottomNavigationBar()
        navigationBar.backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        navigationBar.helpButton.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)
        view = navigationBar
        return navigationBar
    }

    func onDeinit() {

    }

    @objc private func backButtonClicked() {
        backButtonCallback?()
    }

    @objc private func helpButtonClicked() {
        helpButtonCallback?()
    }
}
