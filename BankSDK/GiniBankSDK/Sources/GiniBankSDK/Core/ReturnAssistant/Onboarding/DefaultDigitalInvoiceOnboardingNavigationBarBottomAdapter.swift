//
//  DefaultDigitalInvoiceOnboardingNavigationBarBottomAdapter.swift
//  
//
//  Created by David Vizaknai on 10.02.2023.
//

import UIKit

class DefaultDigitalInvoiceOnboardingNavigationBarBottomAdapter: DigitalInvoiceOnboardingNavigationBarBottomAdapter {
    private var continueButtonCallback: (() -> Void)?

    // Add the callback whenever the continue button is clicked
    func setContinueButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        continueButtonCallback = callback
    }

    func injectedView() -> UIView {
        let navigationBar = DigitalInvoiceOnboardingBottomNavigationBar()
        navigationBar.continueButton.addTarget(self, action: #selector(continueButtonClicked), for: .touchUpInside)
        return navigationBar
    }

    @objc func continueButtonClicked() {
        continueButtonCallback?()
    }

    func onDeinit() {
        continueButtonCallback = nil
    }
}
