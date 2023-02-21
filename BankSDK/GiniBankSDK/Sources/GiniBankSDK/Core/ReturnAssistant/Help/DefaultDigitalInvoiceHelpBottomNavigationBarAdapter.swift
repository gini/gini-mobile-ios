//
//  DefaultDigitalInvoiceHelpBottomNavigationBarAdapter.swift
//  
//
//  Created by David Vizaknai on 17.02.2023.
//

import UIKit
import GiniCaptureSDK

final class DefaultDigitalInvoiceHelpBottomNavigationBarAdapter: DigitalInvoiceHelpBottomNavigationBarAdapter {
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
