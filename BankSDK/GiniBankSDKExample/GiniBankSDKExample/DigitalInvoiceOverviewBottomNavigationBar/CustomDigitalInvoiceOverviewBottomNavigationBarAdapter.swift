//
//  CustomDigitalInvoiceBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 02.03.2023.
//

import UIKit
import GiniBankSDK

class CustomDigitalInvoiceBottomNavigationBarAdapter: DigitalInvoiceNavigationBarBottomAdapter {
    private var view: CustomDigitalInvoiceBottomNavigationBar?
    private var proceedButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?

    func setProceedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        proceedButtonCallback = callback
    }

    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void) {
        helpButtonCallback = callback
    }

    func updateProceedButtonState(enabled: Bool) {
        view?.setProceedButtonState(enabled: enabled)
    }

    func updateTotalPrice(priceWithCurrencySymbol price: String?) {
        view?.updatePrice(with: price)
    }

    func setupViewsRelated(to view: UIView) {
        self.view?.setupConstraints(relatedTo: view)
    }

    func updateSkontoPercentageBadge(with text: String?) {
        self.view?.updateSkontoPercentageBadge(with: text)
    }

    func updateSkontoPercentageBadgeVisibility(hidden: Bool) {
        self.view?.updateSkontoPercentageBadgeVisibility(hidden: hidden)
    }

    func updateSkontoSavingsInfo(with text: String?) {
        self.view?.updateSkontoSavingsInfo(with: text)
    }

    func updateSkontoSavingsInfoVisibility(hidden: Bool) {
        self.view?.updateSkontoSavingsInfoVisibility(hidden: hidden)
    }

    func injectedView() -> UIView {
        let navigationBar = CustomDigitalInvoiceBottomNavigationBar()
        navigationBar.payButton.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        navigationBar.helpButton.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)
        view = navigationBar
        return navigationBar
    }

    func onDeinit() {

    }

    @objc private func proceedButtonClicked() {
        proceedButtonCallback?()
    }

    @objc private func helpButtonClicked() {
        helpButtonCallback?()
    }
}
