//
//  DefaultDigitalInvoiceOnboardingNavigationBarBottomAdapter.swift
//  
//
//  Created by David Vizaknai on 10.02.2023.
//

import UIKit

class DefaultDigitalInvoiceOnboardingNavigationBarBottomAdapter: DigitalInvoiceOnboardingNavigationBarBottomAdapter {
    private var getStartedButtonCallback: (() -> Void)?

    // Add the callback whenever the get started button is clicked
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        getStartedButtonCallback = callback
    }

    func injectedView() -> UIView {
        let navigationBar = DigitalInvoiceOnboardingBottomNavigationBar()
        navigationBar.getStartedButton.addTarget(self, action: #selector(getStartedButtonClicked), for: .touchUpInside)
        return navigationBar
    }

    @objc func getStartedButtonClicked() {
        getStartedButtonCallback?()
    }

    func onDeinit() {
        getStartedButtonCallback = nil
    }
}
