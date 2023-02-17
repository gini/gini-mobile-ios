//
//  CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 10.02.2023.
//

import UIKit
import GiniBankSDK

class CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter: DigitalInvoiceOnboardingNavigationBarBottomAdapter {
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        buttonClicked = callback
    }

    private var buttonClicked: (() -> Void)?

    @objc func actionPressed() {
        buttonClicked?()
    }

    func injectedView() -> UIView {
        let view = CustomDigitalInvoiceOnboardingBottomNavigationBar()
        view.getStartedButton.addTarget(self, action: #selector(actionPressed), for: .touchUpInside)
        return view
    }

    func onDeinit() {
        buttonClicked = nil
    }
}
